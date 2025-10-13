FROM dart:stable

WORKDIR /app

# Copy pubspec first and fetch dependencies (cached layer)
COPY pubspec.* ./
RUN dart pub get

# Copy the rest of your code
COPY . .

# Run your Dart API
CMD ["dart", "bin/server.dart"]