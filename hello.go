package main

import (
	"fmt"
	"log"
	"net/http"
)

// HelloServer responds to requests with the given URL path.
func HelloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
	log.Printf("Received request for path: %s", r.URL.Path)
}

func main() {
	var addr string = ":8080"
	handler := http.HandlerFunc(HelloServer)
	log.Printf("Starting webserver on %s", addr)
	if err := http.ListenAndServe(addr, handler); err != nil {
		log.Fatalf("Could not listen on port %s %v", addr, err)
	}
}
