
# Stock Average Calculator

A simple web application, built with Flask, to calculate the average cost of your stock shares after multiple purchases (average down or up).

## Features

-   Calculate the weighted average price of your stock shares.
-   Dynamically add more purchase entries.
-   Simple, clean, and mobile-friendly user interface.
-   Ready for deployment on Google Cloud Run.

## Tech Stack

-   **Backend**: Python, Flask
-   **WSGI Server**: Gunicorn
-   **Containerization**: Docker
-   **Deployment**: Google Cloud Run, Google Cloud Build

## Local Development

To run this application on your local machine, follow these steps:

1.  **Clone the repository:**

    ```bash
    git clone <your-repository-url>
    cd sac
    ```

2.  **Create a virtual environment (recommended):**

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    # On Windows, use: venv\Scripts\activate
    ```

3.  **Install the dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the Flask development server:**

    ```bash
    python app.py
    ```

5.  Open your web browser and navigate to `http://127.0.0.1:5000`.

## Deployment to Google Cloud Run

This project is configured for easy deployment to Google Cloud Run using the provided `deploy.sh` script.

### Prerequisites

-   [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated (`gcloud auth login`).
-   [Docker](https://docs.docker.com/get-docker/) installed and running.
-   A Google Cloud Project with the **Artifact Registry API** and **Cloud Run API** enabled.

### Deployment Steps

1.  **Set your Project ID:**

    You must specify your Google Cloud Project ID. You can do this by setting an environment variable:

    ```bash
    export PROJECT_ID="your-gcp-project-id"
    ```

    Alternatively, you can edit the `deploy.sh` script and change the default value.

2.  **Run the deployment script:**

    ```bash
    ./deploy.sh
    ```

The script will automatically:
-   Enable the required Google Cloud services.
-   Create an Artifact Registry repository if it doesn't exist.
-   Build the Docker container image.
-   Push the image to your project's Artifact Registry.
-   Deploy the image to a new Cloud Run service.

After the script finishes, it will provide you with the URL to your live application.
