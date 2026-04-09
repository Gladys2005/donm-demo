# Multi-stage build for Flutter app
FROM dart:stable as flutter-base

# Install Flutter
RUN git clone --depth 1 https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
ENV FLUTTER_ROOT=/usr/local/flutter

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure Flutter
RUN flutter channel stable && \
    flutter upgrade && \
    flutter config --enable-web

# Set work directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Download dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build stage for web
FROM flutter-base as web
ENV FLUTTER_WEB_CANVASKIT_RENDERER=html

# Build web app
RUN flutter build web --release --no-web-resources-cdn

# Production web server
FROM nginx:alpine as web-production

# Copy built web app
COPY --from=web /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx/web.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# Build stage for Android APK
FROM flutter-base as android

# Install Android SDK and build tools
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# Download Android command line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -o /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Install Android SDK components
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses && \
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "build-tools;33.0.2" \
    "platforms;android-33"

# Copy source code
COPY . .

# Generate key for signing (in production, use your own keystore)
RUN keytool -genkey -v -keystore /tmp/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=DonM, OU=DonM, O=DonM, L=Abidjan, ST=Abidjan, C=CI" \
    -storepass donmkey -keypass donmkey

# Build APK
RUN flutter build apk --release \
    --dart-define=FLUTTER_WEB_CANVASKIT_RENDERER=html \
    --dart-define=API_URL=https://api.donm.ci \
    --dart-define=GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY} \
    --dart-define=FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}

# Build stage for iOS (requires macOS)
# FROM flutter-base as ios
# RUN flutter build ios --release --no-codesign

# Development stage
FROM flutter-base as development
ENV FLUTTER_WEB_CANVASKIT_RENDERER=html

# Install development dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Expose port for development server
EXPOSE 3000

# Start development server
CMD ["flutter", "run", "-d", "web-server", "--web-port=3000", "--release"]

# Production stage for web
FROM web-production as production
LABEL maintainer="DonM Team <support@donm.ci>"
LABEL version="1.0.0"
LABEL description="DonM Flutter Web Application"

# Add custom nginx configuration
COPY docker/nginx/production.conf /etc/nginx/conf.d/default.conf

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Configure nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
