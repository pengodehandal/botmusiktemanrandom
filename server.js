const http = require('http');
const path = require('path');

const dir = path.join(__dirname);
process.env.NODE_ENV = 'production';
process.chdir(__dirname);

const currentPort = parseInt(process.env.PORT, 10) || 3000;
const hostname = process.env.HOSTNAME || '0.0.0.0';

const htmlContent = `<!DOCTYPE html>
<html>
<head>
    <link rel="icon" href="https://raw.githubusercontent.com/pengodehandal/botmusiktemanrandom/refs/heads/main/ChatGPT%20Image%2018%20Okt%202025%2C%2018.14.52.png" type="image/x-icon">
    <meta name="keywords" content="Indonesia">
    <meta name="description" content="Halo admin:)">
    <meta name="og:title" content="AstarGanz">
    <meta http-equiv="cache-control" content="index,cache">
    <meta http-equiv="pragma" content="index,cache">
    <title>#HackerPatahHati</title>
    <link href="https://fonts.googleapis.com/css?family=Kelly+Slab" rel="stylesheet" type="text/css">
    <style>
        html, body {
            color: #FFFFFF;
            font-family: 'Kelly Slab', sans-serif;
            font-weight: 60;
            height: 60vh;
            margin: 0;
        }
        .full-height {
            height: 67vh;
        }
        .flex-center {
            align-items: center;
            display: flex;
            justify-content: center;
        }
        .position-ref {
            position: relative;
        }
        .content {
            text-align: center;
        }
        .title {
            font-size: 36px;
            padding: 20px;
        }
        input {
            background: transparent;
            color: black;
            border: 1px solid black;
        }
        input:hover {
            color: black;
        }
        /* Style tambahan */
        img[alt="www.000webhost.com"] {
            display: none;
        }
        body {
            background-color: black;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
        }
        .stars {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: black;
            z-index: -1;
        }
    </style>
</head>

<body align="center" oncontextmenu="return false">
    <div class="stars">
        <div class="twinkling">
            <div class="flex-center position-ref full-height">
                <div class="content">
                    <div class="text">
                        <font color="white">
                            <center>
                                <br> <br> <br>
                            <!-- Perbaikan: Mengganti tag video dengan tag img -->
                            <img src="https://wallpapercave.com/wp/wp7157990.jpg" alt="Foto tampilan" style="width:100%; max-width:300px; border-radius:8px;">
                            <br>
                            <i>
                                <font color="red" size="9"> Hacked By <font color="white"> AstarGanz X Bboscat X Heru1337</font></font>
                                <br>
                                <font size="2" color="white"> 
                                  <p>Sorry ye admin</p>
                                </font>
                            </i>
                            <font color="white" size="6">
                                <font color="red">
                                    <font size="3" color="white">
                                        <font color="white" size="3">| GalauCrew | Hacker Patah Hati | Typical Idiot Security | Manusia Biasa Team | Garuda Suspend Commision |</font>
                                        <br><br>
                                        <audio controls loop autoplay="true">
                                            <source src="https://github.com/pengodehandal/botmusiktemanrandom/raw/refs/heads/main/NDX%20AKA%20-%20Nemen%20HipHop%20Dangdut%20Version%20(%20Official%20Lyric%20Video%20).mp3" type="audio/mpeg" />
                                        </audio>
                                    </font>
                                </font>
                            </font>
                        </font>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>`;

// Buat server HTTP sederhana
const server = http.createServer((req, res) => {
    // Atur header untuk response HTML
    res.writeHead(200, {
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0'
    });
    
    // Kirim konten HTML
    res.end(htmlContent);
});

// Jalankan server
server.listen(currentPort, hostname, () => {
    console.log(`Server berjalan di http://${hostname}:${currentPort}`);
    console.log('Menampilkan halaman custom...');
});

// Tangani error
server.on('error', (err) => {
    console.error('Error pada server:', err);
    process.exit(1);
});
