# start-console

Start OKD console for k8s

This project contains a script that, when run while logged into a k8s cluster as an admin user, opens a local web UI using the OKD project's console. It uses the web UI console container image with podman and connects it to a service account with admin privileges.

## Usage

## Run from code

To run the script from the code, use the following command:

1. Ensure you're logged into your Kubernetes cluster as an admin.  
2. Run the script locally:  
```bash
   ./start-console.sh
```

3. Access the console URL printed by the script.

### Run Directly from GitHub

To run the script directly from GitHub, use the following command:

1. Ensure you're logged into your Kubernetes cluster as an admin.  
2. Run the script from github: 
```bash
curl -sSL https://raw.githubusercontent.com/yaacov/start-console/main/start-console.sh | bash
```

## License

This project is licensed under the Apache License, Version 2.0. See the [LICENSE](LICENSE) file for more details.
