package main

import (
	"fmt"
	"github.com/jlaffaye/ftp"
	"os"
	"time"
)

func testUser(ftpConnection *ftp.ServerConn, username string, password string) {
	error := ftpConnection.Login(username, password)
	if error != nil {
		fmt.Println("Login failed")
	}

}

func main() {
	server_addr := fmt.Sprintf("%s:%s", os.Args[1], os.Args[2])
	connection, con_error := ftp.Dial(server_addr, ftp.DialWithTimeout(5*time.Second))
	if con_error != nil {
		fmt.Println(con_error)
		os.Exit(-1)
	}
	testUser(connection, "root", "toor")

}
