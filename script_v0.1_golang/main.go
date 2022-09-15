package main

import (
	"flag"
	"log"
	"os/exec"
	"os/user"
)

func main() {
	var (
		username     = flag.String("user", "openmsa", "User name")
		password     = flag.String("pass", "openmsa", "Password")
		install_type = flag.String("type", "client", "Installation Type (server, client-default)")
	)
	flag.Parse()

	log.Println("username:", *username)
	log.Println("password:", *password)
	log.Println("install_type:", *install_type)
	log.Println("tails:", flag.Args())

	log.Println("######################################")
	// pre_required()
	log.Println("######################################")
	user_create(*username, *password)
	log.Println("######################################")

}

/* Pre-Required Installer */

func pre_required() {

	packages_server := []string{
		"software-properties-common", "openssh-server", "sshpass",
		"ansible", "tree", "curl", "wget"}

	pacakges_client := []string{
		"openssh-client", "curl", "wget"}

	log.Println("server package:", packages_server)
	log.Println("client package:", pacakges_client)

	package_update()
	package_install(pacakges_client)
}

func package_update() {
	apt_update := exec.Command("sudo", "apt-get", "update")
	apt_update.Start()
	apt_update.Wait()
}

func package_install(packages []string) {
	for _, pkgname := range packages {
		log.Printf("Package install [%s] ", pkgname)
		cmd := exec.Command("sudo", "apt-get", "install", pkgname, "-y")

		if err := cmd.Start(); err != nil {
			log.Fatalf("ERROR : %v", err)
		}

		if err := cmd.Wait(); err != nil {
			if exiterr, ok := err.(*exec.ExitError); ok {
				log.Printf("Exit Status: %d", exiterr.ExitCode())
			} else {
				log.Fatalf("cmd.Wait: %v", err)
			}
		}
	}
}

/* User Command*/
func user_create(user, pass string) {
	log.Println("Create User [", user, "]")
	exist_user(user, pass)
}

/*
@param
  - string user : user명

유저가 있는지 확인 (id -u {username})
*/
func exist_user(username, password string) bool {
	u, err := user.Lookup(username)
	if err != nil {
		log.Printf("%s", err)
		if add_user(username) {
			set_password_user(username, password)
			set_sudo_user(username)
		}

		return true
	}
	log.Println("already exist [", username, "]")
	log.Println("UserName: ", u.Username)
	log.Println("UserName: ", u.HomeDir)
	return true
}

func add_user(username string) bool {
	log.Println("start ADD USER")
	userhome := "/home/" + username
	cmd := exec.Command(
		"sudo", "adduser",
		"--quiet", "--disabled-password",
		"--shell", "/bin/bash",
		"--home", userhome,
		"--gecos", "",
		username)
	if err := cmd.Start(); err != nil {
		log.Fatalf("ERROR : %v", err)
		return false
	}

	if err := cmd.Wait(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			log.Printf("Exit Status: %d", exiterr.ExitCode())
			return false
		} else {
			log.Fatalf("cmd.Wait: %v", err)
			return false
		}
	}
	return true
}

func set_password_user(username, password string) bool {
	log.Println("SET SUDO USER")
	setting_password := username + ":" + password
	cmd := exec.Command(
		"echo", setting_password,
		"|",
		"sudo", "chpasswd")

	if err := cmd.Start(); err != nil {
		log.Fatalf("ERROR : %v", err)
		return false
	}

	if err := cmd.Wait(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			log.Printf("Exit Status: %d", exiterr.ExitCode())
			return false
		} else {
			log.Fatalf("cmd.Wait: %v", err)
			return false
		}
	}
	return true
}

func set_sudo_user(username string) bool {
	log.Println("sudo 권한 부여")
	cmd := exec.Command(
		"sudo", "usermod", "-aG", "sudo", username)

	if err := cmd.Start(); err != nil {
		log.Fatalf("ERROR : %v", err)
		return false
	}

	if err := cmd.Wait(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			log.Printf("Exit Status: %d", exiterr.ExitCode())
			return false
		} else {
			log.Fatalf("cmd.Wait: %v", err)
			return false
		}
	}
	return true
}

// 생성
