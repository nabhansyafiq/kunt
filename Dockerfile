# Menggunakan image resmi Node.js sebagai dasar
FROM node:16

# Menyetel nama pengguna dan grup untuk pengguna aplikasi
RUN groupadd -r pterodactyl && useradd -r -g pterodactyl -G sudo -m -d /home/pterodactyl -s /bin/bash pterodactyl

# Menyalin file package.json ke direktori kerja
COPY package.json /home/pterodactyl/package.json

# Menyetel direktori kerja
WORKDIR /home/pterodactyl

# Mengatur hak akses untuk direktori kerja
RUN chown -R pterodactyl:pterodactyl /home/pterodactyl

# Menginstal paket @pterodactyl/panel dari GitHub
RUN npm install https://github.com/pterodactyl/panel.git

# Menjalankan perintah instalasi
RUN npm install

# Menjalankan perintah untuk memulai aplikasi
RUN npm run key:generate
RUN npm run migrate
RUN npm run db:seed

# Menambahkan pengguna admin
RUN wings user:create --username rifki --email muhammadrifqilkhanif@gmail.com --password batagorG30po --admin

# Mengatur port untuk aplikasi
EXPOSE 8080

# Menjalankan perintah untuk memulai aplikasi
CMD ["npm", "start"]
