# Garbage-Classifier

Here's a step-by-step guide on how to build Docker images and run the containers using Docker Compose:

---

## Step 1: Clone this repo

Open your terminal/command prompt and go to the folder containing this repo.

```bash
git clone https://github.com/sahil-sharma-50/garbage-classifier.git
```

---

## Step 2: Build Docker images

Run this command to build **both** the backend and frontend images defined in `docker-compose.yml`.

```bash
docker-compose build
```

* This will read the Dockerfiles (`Dockerfile.backend` and `Dockerfile.frontend`) and build images for each service.

---

## Step 3: Run the containers

Once built, start app with:

```bash
docker-compose up
```

* This will start both backend and frontend containers, attach their logs to your terminal, and map ports (`8000` and `3000`) to your host machine.

* You can now access:

  * Backend FastAPI API at: [http://localhost:8000/predict](http://localhost:8000/predict) (or your IP)
  * React frontend at: [http://localhost:3000](http://localhost:3000)

---

## Step 4 (Optional): Run containers in detached mode

If you want to run containers in the background, add the `-d` flag:

```bash
docker-compose up -d
```

* Your terminal will be free for other commands, but containers will keep running.

---

## Step 5: Check running containers

To see your running containers, use:

```bash
docker ps
```

---

## Step 6: Stopping the containers

To stop the running containers:

```bash
docker-compose down
```

This stops and removes the containers, networks, and default volumes created by Compose.

---

## Summary of useful commands

| Command                | Description                         |
| ---------------------- | ----------------------------------- |
| `docker-compose build` | Build images for all services       |
| `docker-compose up`    | Start containers and attach logs    |
| `docker-compose up -d` | Start containers in detached mode   |
| `docker-compose down`  | Stop and remove containers/networks |
| `docker ps`            | List running containers             |

---
