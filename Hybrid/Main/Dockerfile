FROM ghcr.io/cirruslabs/flutter:3.35.6 AS build
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
ARG API_URL
RUN flutter build web --release --dart-define=API_URL=$API_URL

FROM nginx:alpine AS production
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
