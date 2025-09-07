package main

import (
	"encoding/json"
	// "fmt"
	"net"
	"log"
	// "github.com/go-acme/lego/v4/challenge"
	// "github.com/go-acme/lego/v4/providers/dns/cloudflare"
	// "github.com/go-acme/lego/v4/providers/dns/digitalocean"
	// "github.com/go-acme/lego/v4/providers/dns/route53"
)

// Response struct to return as JSON
type Response struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}


// Send JSON response to the client
func sendResponse(conn net.Conn, status, message string) {
	response := Response{
		Status:  status,
		Message: message,
	}
	encoder := json.NewEncoder(conn)
	err := encoder.Encode(response)
	if err != nil {
		log.Printf("❌ Error sending response: %v\n", err)
	}
}
