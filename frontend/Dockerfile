# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# Resolves dependencies
RUN flutter pub get

# Build the web artifact
# Passing API_BASE_URL as a build argument
ARG API_BASE_URL
RUN flutter build web --dart-define=API_BASE_URL=${API_BASE_URL}

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
