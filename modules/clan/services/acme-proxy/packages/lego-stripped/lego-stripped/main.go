package main

import (
	"encoding/json"
	"github.com/go-acme/lego/v4/challenge"
	"fmt"
	"log"
	"net"
	"os"
)


// Request struct to hold incoming JSON data
type Request struct {
	Action   string `json:"action"`
	Domain   string `json:"domain"`
	Token    string `json:"token"`
	KeyAuth  string `json:"keyAuth"`
}

func main() {
	// Get the provider name from the environment variable
	providerName := os.Getenv("DNS_PROVIDER")
	if providerName == "" {
		fmt.Println("❌ DNS_PROVIDER environment variable is not set.")
		os.Exit(1)
	}

	socketPath := os.Getenv("SOCKET_PATH")
	if socketPath == "" {
		fmt.Println("❌ SOCKET_PATH environment variable is not set.")
		os.Exit(1)
	}

	provider, err := NewDNSChallengeProviderByName(providerName)
	if err != nil {
		log.Printf("❌ Error loading provider '%s' : %v\n Make sure to enable it by uncommenting it in ./provider.go", providerName, err)
		return
	}
	// Remove any existing socket file to avoid errors
	if _, err := os.Stat(socketPath); err == nil {
		err := os.Remove(socketPath)
		if err != nil {
			log.Fatalf("Failed to remove existing socket file: %v\n", err)
		}
	}

	// Listen for incoming connections on the Unix socket
	listener, err := net.Listen("unix", socketPath)
	if err != nil {
		log.Fatalf("Error starting server: %v\n", err)
	}
	defer listener.Close()

	fmt.Printf("Server listening on %s...\n", socketPath)

	// Accept connections and handle them
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection: %v\n", err)
			continue
		}

		// Handle the connection in a new goroutine
		go handleConnection(conn, provider)
	}
}

// Function to handle incoming connections
func handleConnection(conn net.Conn, provider challenge.Provider) {
	defer conn.Close()

	// Decode the incoming JSON request
	var req Request
	decoder := json.NewDecoder(conn)
	err := decoder.Decode(&req)
	if err != nil {
		log.Printf("❌ Error decoding request: %v\n", err)
		sendResponse(conn, "error", fmt.Sprintf("Failed to decode request: %v", err))
		return
	}

	// Dynamically load the provider

	// Execute the appropriate action (present or cleanup)
	var message string
	switch req.Action {
	case "present":
		err = provider.Present(req.Domain, req.Token, req.KeyAuth)
		message = fmt.Sprintf("Successfully executed 'present' for %s", req.Domain)
	case "cleanup":
		err = provider.CleanUp(req.Domain, req.Token, req.KeyAuth)
		message = fmt.Sprintf("Successfully executed 'cleanup' for %s", req.Domain)
	default:
		log.Println("❌ Invalid action. Use 'present' or 'cleanup'")
		sendResponse(conn, "error", "Invalid action. Use 'present' or 'cleanup'")
		return
	}

	// Send response back as JSON
	if err != nil {
		sendResponse(conn, "error", fmt.Sprintf("Error executing action: %v", err))
	} else {
		sendResponse(conn, "success", message)
	}
}
