# Menggunakan image resmi Node.js sebagai dasar
FROM node:16

# Menyetel nama pengguna dan grup untuk pengguna aplikasi
RUN groupadd -r pterodactyl && useradd -r -g pterodactyl -G sudo -m -d /home/pterodactyl -s /bin/bash pterodactyl

# Menyetel direktori kerja
WORKDIR /home/pterodactyl

# Menyalin file .env.example ke direktori kerja
COPY .env.example .env

# Mengatur variabel lingkungan
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV APP_URL=http://localhost
ENV DB_CONNECTION=mysql
ENV DB_HOST=junction.proxy.rlwy.net
ENV DB_PORT=52860
ENV DB_DATABASE=railway
ENV DB_USERNAME=root
ENV DB_PASSWORD=EdFepEFOowrxYUCsjoeMaQjjaejwGgWH
ENV PTERODACTYL_TOKEN_ID=
ENV PTERODACTYL_TOKEN_SECRET=

# Menambahkan pengguna dan grup ke direktori kerja
RUN chown -R pterodactyl:pterodactyl /home/pterodactyl

# Menjalankan perintah instalasi
RUN npm install -g wings
RUN npm install
RUN npm run key:generate
RUN npm run migrate
RUN npm run db:seed

# Menambahkan pengguna admin
RUN wings user:create --username rifki --email muhammadrifqilkhanif@gmail.com --password batagorG30po --admin

# Menjalankan perintah untuk memulai aplikasi
CMD ["npm", "run", "serve"]
