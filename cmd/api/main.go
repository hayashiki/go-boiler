package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	goboler "github.com/hayashiki/go-boiler"
	"google.golang.org/api/iterator"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/rs/cors"

	"cloud.google.com/go/storage"
)

func main() {
	r := chi.NewRouter()
	// CORS
	r.Use(cors.New(cors.Options{
		AllowedOrigins:   strings.Split("0.0.0.0, localhost", ","), // TODO: devだけ制限
		AllowedMethods:   []string{http.MethodGet, http.MethodPost, http.MethodOptions},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true,
	}).Handler)

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(30 * time.Second))
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	r.Get("/", health)
	r.Post("/", health)
	r.Get("/health", health)
	r.Get("/gcs", gcs)
	log.Print("Listening on port 8080")
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), r))
}

func health(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, goboler.Version(), goboler.Revision())
}

// GCSのロールを与えて権限確認する
func gcs(w http.ResponseWriter, r *http.Request) {
	gcsClient, err := storage.NewClient(r.Context())
	if err != nil {
		return
	}
	defer func() {
		err := gcsClient.Close()
		if err != nil {
			fmt.Printf("fail to close: err: %v", err)
		}
	}()

	br, err := gcsClient.Bucket("go-boiler-ping").Object("14979322415886A.jpg").NewReader(r.Context())
	it := gcsClient.Bucket("go-boiler-ping").Objects(r.Context(), nil)
	for {
		attrs, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		log.Printf(attrs.Name)
	}
	if err != nil {
		log.Printf("err %v", err)
	}
	b, err := io.ReadAll(br)
	if err != nil {
		log.Printf("err %v", err)
	}
	////log.Printf("string %s", string)
	w.Write(b)
}

//func getIam(w http.ResponseWriter, r *http.Request) {
//	cred, err := google.DefaultClient(r.Context(), iam.CloudPlatformScope)
//	if err != nil {
//		log.Printf("failed to initialize the Google client.\n")
//		log.Printf("%v\n", err.Error())
//		return
//	}
//
//	iamService, err := iam.NewService(r.Context(), option.WithHTTPClient(cred))
//	if err != nil {
//		log.Printf("failed to initialize the IAM.")
//		return
//	}
//}
