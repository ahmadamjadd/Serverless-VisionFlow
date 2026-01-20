# Serverless-VisionFlow

**Serverless-VisionFlow** is a fully automated, serverless image processing pipeline built on AWS. It uses **Infrastructure as Code (IaC)** with Terraform to provision resources and utilizes **AWS Lambda Layers** to manage heavy dependencies like OpenCV efficiently.

When a user uploads an image to a source S3 bucket, it automatically triggers a Lambda function that resizes the image, converts it to grayscale, stores the result in a destination bucket, and sends an email notification via SNS.

## 🚀 Key Features

* **Event-Driven Architecture**: Automatically triggers processing upon image upload (`s3:ObjectCreated`).
* **Image Processing**: Uses **OpenCV (cv2)** to convert images to grayscale and resize them to 50% of their original dimensions.
* **Lambda Layers**: Implements AWS Lambda Layers to package and manage the OpenCV library, keeping the deployment package lightweight.
* **Notifications**: Integrated Amazon SNS to send email alerts upon successful processing.
* **Infrastructure as Code**: Entire infrastructure is defined and deployed using **Terraform**.

## 🛠️ Architecture

1.  **Source S3 Bucket**: User uploads a `.jpg` image.
2.  **S3 Notification**: Triggers the Lambda function.
3.  **AWS Lambda**:
    * Loads OpenCV from the attached **Lambda Layer**.
    * Downloads the image.
    * Processes the image (Grayscale + Resize).
    * Uploads the processed image to the **Destination S3 Bucket**.
4.  **Amazon SNS**: Publishes a message to a topic, sending an email subscription alert.

## 📂 Project Structure

```text
Serverless-VisionFlow/
├── main.tf                 # Terraform configuration for AWS resources
├── imageresizer.py         # Python Lambda function logic
├── opencv_layer/           # Directory containing the OpenCV zip for the Layer
│   └── opencv_layer.zip    
└── README.md               # Project documentation
```

## ⚙️ Prerequisites

* **AWS Account**: With appropriate permissions to create S3 buckets, Lambda functions, IAM roles, and SNS topics.
* **Terraform**: Installed on your local machine (v1.0+).
* **Python**: Python 3.12 installed.

## 🚀 Deployment Guide

### 1. Clone the Repository

```bash
git clone [https://github.com/ahmadamjadd/Serverless-VisionFlow.git](https://github.com/ahmadamjadd/Serverless-VisionFlow.git)
cd Serverless-VisionFlow
```

### 2. Prepare the OpenCV Layer

Ensure you have the `opencv-layer.zip` file ready[cite: 105]. This project uses a Lambda Layer to separate the heavy OpenCV library from the core logic.

> **Note:** If you need to rebuild the layer, ensure it is compatible with Python 3.12 and the x86_64 architecture.

### 3. Initialize Terraform

Initialize the working directory containing Terraform configuration files.

```bash
terraform init
```

### 3. Review and Apply

Check the execution plan and apply the changes to create the infrastructure.

```bash
terraform plan
terraform apply
```

* Type `yes` when prompted.

### 5. Confirm Subscription

Check the email inbox you defined in `main.tf`. You will receive a "Subscription Confirmation" email from AWS SNS. Click the link to confirm the subscription.

## 🧪 Usage

1.  Log in to the AWS Console or use the AWS CLI.
2.  Navigate to the source bucket created by Terraform (e.g., `image-resizer-source-908`).
3.  Upload a `.jpg` file.
4.  Check the **Destination Bucket** (`image-resizer-destination-908`) for the processed image (prefixed with `processed-`).
5.  Check your email for the success notification.

## 🔧 Technical Implementation Details

### Terraform Resources

* **S3 Buckets**: Source, Destination, and Layer storage.
* **Lambda Function**: configured with `Python 3.12` runtime.
* **Lambda Layer**: Attached to the function to provide `cv2` and `numpy`.
* **IAM Roles & Policies**: Least privilege policies granting access strictly to the specific S3 buckets and SNS topic.

### OpenCV Layer

This project was a specific implementation exercise in using **Lambda Layers**. By abstracting OpenCV into a layer, the main function code remains clean and the deployment updates are significantly faster since the heavy library doesn't need to be re-uploaded with every code change.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/ahmadamjadd/Serverless-VisionFlow/issues).

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).