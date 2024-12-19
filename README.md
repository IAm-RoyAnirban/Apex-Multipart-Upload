# Salesforce - Upload Multipart-Form Data Using Apex Trigger
This project demonstrates how to upload multipart-form data using an Apex Trigger in Salesforce to seamlessly integrate with Google Drive and OpenAI Vector Store simultaneously.

### Watch the video demo to learn more:
##### [Perform Multipart-Form Data Uploads Using Apex Trigger to Google Drive or OpenAI Vector Store in Salesforce](https://youtube.com/)

### Overview
This solution is designed for developers and Salesforce admins looking to:

- Automate bulk file uploads in Salesforce.
- Handle dynamic file types (e.g., PDF, documents, images, text) efficiently.
- Integrate Salesforce with external APIs like Google Drive and OpenAI for document storage and AI processing.

### Key Features
- Bulkified Apex Trigger to handle large-scale operations.
- Multipart-form data creation for API compatibility.
- Parallel file uploads to both Google Drive and OpenAI Vector Store.
- Support for multiple file types in a single operation.
- API error handling and optimization for Salesforce limits.
- Test class included.

## Getting Started

### Prerequisites
Before using this solution, ensure that you have the following:

- **Salesforce Developer Org**: A Salesforce Developer Edition, Scratch, or Sandbox org with API access enabled.
- **Google Drive API Credentials**: You’ll need access to the Google Drive API and OAuth credentials to allow file uploads.
- **OpenAI API Credentials**: Set up an API key for accessing OpenAI services (such as the Vector Store).
- **Basic Knowledge of Salesforce Apex**: Understanding of Apex Triggers, API integrations, and asynchronous processing.

## Installation Steps

### Clone the Repository
Clone or download this repository to your Salesforce Developer Org. You will need to deploy the Apex Trigger, Apex class, and custom settings.

### Set Up Google Drive API
1. Go to the [Google Developers Console](https://console.cloud.google.com/).
2. Create a new project and enable the Google Drive API.
3. Set up OAuth 2.0 credentials and download the JSON credentials file.
4. Configure the same as Auth Provider, External Credential, and Named Credentials into Salesforce.

### Set Up OpenAI API
1. Visit [OpenAI's platform](https://platform.openai.com/api-keys) to create an account and obtain your API key.
2. Configure the same as External Credential Named Credentials into Salesforce.

### Deploy the Apex Trigger and Class
1. Use the Salesforce Developer Console or your IDE (VS Code, Illuminated Cloud) to deploy the provided Apex Trigger and class to your Salesforce Org.

### Watch the YouTube Video for the Demo

## How It Works
This solution uses an Apex Trigger to handle the upload of files. The trigger processes all the files uploaded to Salesforce (such as documents or images), converts them into multipart-form data, and then uploads them simultaneously to both Google Drive and OpenAI Vector Store.

### Flow of the Process:
- **File Upload in Salesforce**: When a file is added to Salesforce (e.g., an attachment to a record or a new content version), the Apex Trigger is invoked.
- **Multipart-form Data Creation**: The Apex code converts the file(s) into multipart-form format, suitable for uploading to external APIs.
- **Parallel API Calls**: The Apex Trigger uses asynchronous processing (via @future or batch processing) to send the files to both Google Drive and OpenAI Vector Store.
- **Error Handling**: If any file fails to upload, an error message is captured and logged for troubleshooting.

### Contributions
Feel free to fork this repository and contribute by submitting issues or pull requests. If you encounter any issues or need additional features, please raise a GitHub issue.

### License
This project is licensed under the MIT License - see the [LICENSE file](https://github.com/IAm-RoyAnirban/Apex-Multipart-Upload/blob/main_branch/LICENSE) for more details.
