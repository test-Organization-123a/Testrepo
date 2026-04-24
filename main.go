package main

import (
	"fmt"

	"github.com/bugsnag/bugsnag-go/v2"
)

func main() {
	bugsnag.Configure(bugsnag.Configuration{
		APIKey:          "f50eb301497a079219b10af77e33457c",
		ProjectPackages: []string{"main"},
		Synchronous:     true,
	})

	err := fmt.Errorf("Central API Test Error: Database connection timeout")

	metaData := bugsnag.MetaData{
		"AggregatorContext": {
			"GitHubURL": "https://github.com/test-Organization-123a/Testrepo",
		},
	}
	fmt.Println("Spamming Bugsnag...")
	for i := 0; i < 1; i++ {
		notifyErr := bugsnag.Notify(err, metaData)
		if notifyErr != nil {
			fmt.Printf("Bugsnag SDK wddwwdwddwwddwdwwdfailed to send: %v\n", notifyErr)
			return
		}
	}
	fmt.Println("\nDone!eee")
}
