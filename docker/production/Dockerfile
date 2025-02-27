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
RUN npm install --production
COPY . .
ENV NODE_ENV=production
RUN npm run build

# Stage de production
FROM nginx:alpine
COPY --from=building /app/build /usr/share/nginx/html
COPY docker/production/nginx.conf /etc/nginx/conf.d/default.conf
ENV ENVIRONMENT=production
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
