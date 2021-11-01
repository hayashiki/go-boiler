package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/rs/cors"
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
	log.Print("Listening on port 8080")
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), r))
}

func health(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "v0.0.1")
}
