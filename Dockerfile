FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Copier et télécharger les dépendances d'abord
COPY pom.xml .
RUN mvn dependency:go-offline

# Copier le code source et compiler
COPY src ./src
RUN mvn clean package -DskipTests

# Vérifier le contenu du dossier target
RUN ls -la /app/target/

FROM eclipse-temurin:17-jdk-alpine
# Copier le fichier WAR (pas JAR) et le renommer en app.war
COPY --from=build /app/target/*.war /app.war

# Vérifier que le fichier a bien été copié
RUN ls -la /app.war

# Utiliser java -jar avec le fichier WAR (Spring Boot sait exécuter les WAR)
ENTRYPOINT ["java", "-jar", "/app.war"]
