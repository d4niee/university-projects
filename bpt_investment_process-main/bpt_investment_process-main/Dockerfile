FROM node:latest
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN chmod +x ./launch.sh
CMD ["./launch.sh"]
