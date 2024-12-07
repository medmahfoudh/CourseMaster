# Build Backend
FROM maven:3.8.7-eclipse-temurin-17 as backend-build
WORKDIR /backend
COPY ./backend/pom.xml ./pom.xml
RUN mvn dependency:go-offline
COPY ./backend/src ./src
RUN mvn package -DskipTests

# Build Frontend
FROM node:22.12.0 as frontend-build
WORKDIR /frontend
COPY ./frontend/package.json ./package.json
RUN npm install
COPY ./frontend/ .
RUN npm run build --prod

# Runtime Backend
FROM eclipse-temurin:17-jdk as backend-runtime
WORKDIR /app
COPY --from=backend-build /backend/target/*.jar backend.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "backend.jar"]

# Runtime Frontend
FROM nginx:1.21.6 as frontend-runtime
COPY --from=frontend-build /frontend/dist/frontend /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
