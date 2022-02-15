package main

import (
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/dropbox/dropbox-sdk-go-unofficial/v6/dropbox"
	"github.com/dropbox/dropbox-sdk-go-unofficial/v6/dropbox/files"
	"github.com/kelseyhightower/envconfig"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	server()
}

// func quicServer(){
// 	mux := http.NewServeMux()
// 	mux.Handle("/", http.FileServer(http.Dir("public")))
// 	mux.Handle("/upload", http.HandlerFunc(quicUpdate))
// 	http3.ListenAndServeQUIC(":1323", "/etc/nginx/certs/fullchain.pem", "/etc/nginx/certs/privkey.pem", mux)
// }

// func generateTLSConfig() *tls.Config {
// 	key, err := rsa.GenerateKey(rand.Reader, 1024)
// 	if err != nil {
// 		panic(err)
// 	}
// 	template := x509.Certificate{SerialNumber: big.NewInt(1)}
// 	certDER, err := x509.CreateCertificate(rand.Reader, &template, &template, &key.PublicKey, key)
// 	if err != nil {
// 		panic(err)
// 	}
// 	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(key)})
// 	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})

// 	tlsCert, err := tls.X509KeyPair(certPEM, keyPEM)
// 	if err != nil {
// 		panic(err)
// 	}
// 	return &tls.Config{
// 		Certificates: []tls.Certificate{tlsCert},
// 		NextProtos:   []string{"quic-echo-example"},
// 	}
// }

// func quicUpdate(w http.ResponseWriter, r *http.Request){
// 	switch r.Method {
// 	case "POST":
// 		if err := r.ParseForm(); err != nil {
// 			fmt.Fprintf(w, "ParseForm() err: %v", err)
// 			return
// 		}
// 		fmt.Fprintf(w, "Post from website! r.PostFrom = %v\n", r.PostForm)
// 	default:
// 		fmt.Fprintf(w, "Sorry, only POST methods are supported.")
// 	}
// 	w.WriteHeader(http.StatusOK)
// 	fmt.Fprintf(w, "Hello World")
// }

func server() {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Static("/", "public")
	e.POST("/upload", upload)
	e.Logger.Fatal(e.Start(":1323"))
}

type Env struct {
	Token string
}

func upload(c echo.Context) error {
	saveFile(c)
	go handlerDropbox(c)

	return c.JSON(http.StatusOK, "ok")
}

func findToken() string {
	var goenv Env
	envconfig.Process("", &goenv)
	// return "sl.A-qGPcaNGrWhyx8qr-CCEALYm4FITZBnHGobuX9l_rbVzCguQ5NaUuUqh3WVjn6Av84FqUjJTc5i3yezWeDfurtfHt-Ja4GsEygQGUWf4NsudUtNa-Wyk1C23bn7eyGRadqMDZEqnDjW"
}

//save file
func saveFile(c echo.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		panic(err)

	}
	src, err := file.Open()
	if err != nil {
		panic(err)

	}
	defer src.Close()

	// Destination
	dst, err := os.Create(filepath.Join("data", file.Filename))
	if err != nil {
		panic(err)

	}
	defer dst.Close()
	// Copy
	if _, err = io.Copy(dst, src); err != nil {
		panic(err)
	}
}

func handlerDropbox(c echo.Context) {
	token := findToken()

	config := dropbox.Config{
		Token:    token,
		LogLevel: dropbox.LogInfo,
	}

	client := files.New(config)
	file_name, err := c.FormFile("file")
	if err != nil {
		panic(err)
	}
	f, err := os.Open("data/" + file_name.Filename)
	if err != nil {
		panic(err)
	}
	arg := files.NewCommitInfo("/" + file_name.Filename)
	_, err = client.Upload(arg, f)
	print("a")
	if err != nil {
		panic(err)
	}
}
