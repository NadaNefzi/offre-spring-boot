FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Copier et télécharger les dépendances d'abord (pour mieux utiliser le cache)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copier le code source et compiler
COPY src ./src
RUN mvn clean package -DskipTests

# Étape de vérification (optionnelle mais utile pour le debug)
RUN ls -la /app/target/ && echo "Contenu du dossier target:"

FROM eclipse-temurin:17-jdk-alpine
# Utiliser un nom plus explicite, en s'attendant à un seul fichier .jar
# Note: Si plusieurs .jar sont générés, il faudra être plus précis.
COPY --from=build /app/target/*.jar /app.jar

# Vérifier que le fichier a bien été copié (optionnel)
RUN ls -la /app.jar && echo "Fichier app.jar présent dans l'image finale."

ENTRYPOINT ["java", "-jar", "/app.jar"]
