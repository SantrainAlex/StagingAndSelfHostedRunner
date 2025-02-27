# Stage de test
FROM node:21 AS testing
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm test -- --watchAll=false

# Stage de build
FROM node:21 AS building
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV NODE_ENV=staging
RUN npm run build

# Stage de production pour le staging
FROM nginx:alpine
COPY --from=building /app/build /usr/share/nginx/html
COPY docker/staging/nginx.conf /etc/nginx/conf.d/default.conf
ENV ENVIRONMENT=staging
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
