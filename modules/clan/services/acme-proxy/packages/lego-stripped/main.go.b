package main

import (
	"fmt"
	"os"
	"github.com/go-acme/lego/v4/challenge"
	"github.com/go-acme/lego/v4/providers/dns/cloudflare"
	// "github.com/go-acme/lego/v4/providers/dns/digitalocean"
	// "github.com/go-acme/lego/v4/providers/dns/route53"
	// "github.com/go-acme/lego/v4/providers/dns"
)

func main() {
	if len(os.Args) != 6 {
		fmt.Println("Usage: ./lego-dns-wrapper <provider> <present|cleanup> <domain> <token> <keyAuth>")
		os.Exit(1)
	}

	providerName := os.Args[1]
	action := os.Args[2]
	domain := os.Args[3]
	token := os.Args[4]
	keyAuth := os.Args[5]

	// Dynamically load the provider using LEGO's registry
	provider, err := getProvider(providerName)
	if err != nil {
		fmt.Printf("❌ Error loading provider '%s': %v\n", providerName, err)
		os.Exit(1)
	}

	switch action {
	case "present":
		err = provider.Present(domain, token, keyAuth)
	case "cleanup":
		err = provider.CleanUp(domain, token, keyAuth)
	default:
		fmt.Println("❌ Invalid action. Use 'present' or 'cleanup'")
		os.Exit(1)
	}

	if err != nil {
		fmt.Printf("❌ Error executing %s: %v\n", action, err)
		os.Exit(1)
	}

	fmt.Printf("✅ Successfully executed %s for %s using provider '%s'\n", action, domain, providerName)
}

func getProvider(name string) (challenge.Provider, error) {
	switch name {
	case "cloudflare":
		return cloudflare.NewDNSProvider()
	// case "digitalocean":
	// 	return digitalocean.NewDNSProvider()
	// case "route53":
	// 	return route53.NewDNSProvider()
	// Add more providers here
	default:
		return nil, fmt.Errorf("unsupported provider: %s", name)
	}
}
