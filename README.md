# Project David README.md

## Description

Project David is a sophisticated chatbot application designed to facilitate seamless interaction between users and an AI assistant. Built on Ruby on Rails, this project integrates with Facebook Messenger and leverages OpenAI's API for processing and responding to user messages. The bot's backend is structured to handle incoming webhook requests, parse messages, and generate responses using OpenAI's GPT model. The project is structured into several key components: APIs, services, and workers, ensuring a modular and scalable architecture.

## Setup Steps

### Prerequisites
1. Ruby on Rails
2. PostgreSQL (or a preferred database)
3. Sidekiq for background processing
4. An OpenAI API account
5. A Facebook Developer account with a Messenger bot setup

### Configuration
1. **Clone the repository:**
   ```bash
   git clone git@github.com:anchueh/project-david.git
   cd project-david
   ```

2. **Set up environment variables:**
   Copy the `.env.example` file to a new file named `.env` and fill in the required environment variables:
    - `APP_SECRET`: Your application secret key.
    - `PAGE_ACCESS_TOKEN`: Facebook page access token.
    - `VERIFY_TOKEN`: A verification token for the webhook.
    - `PAGE_IDS`: Comma-separated Facebook page IDs.
    - `OPENAI_API_KEY`: Your OpenAI API key.
    - `OPENAI_ASSISTANT_ID`: The OpenAI Assistant ID.
    - Database credentials.

3. **Install dependencies:**
   ```bash
   bundle install
   ```

4. **Database setup:**
   ```bash
   rails db:create db:migrate
   ```

5. **Start the application:**
   ```bash
   rails server
   ```

6. **Start Sidekiq for background processing:**
   In a separate terminal window, run:
   ```bash
   sidekiq
   ```

### Structure Overview

1. **API Endpoints (`app/api`):**
    - `ApplicationAPI`: Base API class.
    - `BotAPI`: Handles the webhook endpoints for Facebook Messenger.

2. **Services (`app/services`):**
    - `BotServices`: Contains services like `HandleMessage` to process incoming messages.
    - `MessengerServices`: Includes services to interact with Facebook Messenger API, such as `SendAction` and `SendMessage`.
    - `OpenAIServices`: Services to communicate with OpenAI API, including message and run creation.

3. **Workers (`app/workers`):**
    - `BotMessageSenderWorker`: A Sidekiq worker responsible for sending processed responses back to the user.

### Webhook Configuration
- Set up the webhook URL in your Facebook app to point to `[your server URL]/bot/webhook`.
- Ensure that the `VERIFY_TOKEN` in your `.env` file matches the token configured in the Facebook app.

### Testing
- Test the application by sending messages to your Facebook page. The bot should respond based on the OpenAI model's output.

## Contributing
Contributions to Project David are welcome. Please follow the standard fork-and-pull request workflow.
