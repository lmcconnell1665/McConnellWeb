---
title: "CI/CD for AI Agents: Deploying LangGraph Applications with GitHub Actions and Docker"
date: 2026-01-28T00:00:00Z
description: "Complete guide to setting up continuous integration and deployment for LangGraph AI agents using GitHub Actions and Docker. Learn how to build, test, and deploy production-ready AI agents with automated workflows, container orchestration, and best practices for AI/ML pipelines."
tags:
- AI Agents
- LangGraph
- LangChain
- GitHub Actions
- Docker
- CI/CD
- DevOps
- Python
- MLOps
categories:
- Tutorial
draft: false
---

***
#### Building AI agents is one thing—deploying them reliably to production is another. Learn how to set up complete CI/CD pipelines for LangGraph agents using GitHub Actions and Docker containers. This tutorial covers automated testing, containerization, registry publishing, and deployment strategies optimized for AI agent workflows.

***

## Introduction: Why CI/CD Matters for AI Agents

AI agents built with LangGraph are sophisticated applications that combine language models, tools, memory systems, and complex orchestration logic. Unlike traditional software, AI agents have unique deployment challenges:

- **Model dependencies**: Large language model integrations require careful version management
- **Environment consistency**: Agents need identical runtime environments across development and production
- **Prompt engineering iterations**: Changes to prompts, tools, and workflows require rapid testing and deployment
- **API key management**: Secure handling of credentials for LLM providers and external services
- **Observability requirements**: Monitoring agent behavior, token usage, and performance metrics

Manual deployment of AI agents is error-prone, slow, and doesn't scale as your team grows. Continuous Integration and Continuous Deployment (CI/CD) solves these problems by automating the entire pipeline from code commit to production deployment.

In this comprehensive guide, we'll build a complete CI/CD workflow using GitHub Actions to:
- Automatically test LangGraph agents on every commit
- Build optimized Docker containers for consistent deployment
- Push container images to registries (Docker Hub, GitHub Container Registry, AWS ECR)
- Deploy agents to cloud platforms with zero downtime
- Monitor deployments and handle rollbacks

***

## What is LangGraph? Understanding Agent Architecture

[LangGraph](https://langchain-ai.github.io/langgraph/) is a framework from LangChain for building stateful, multi-actor applications with language models. Unlike simple chatbots, LangGraph agents can:

- **Maintain conversation state** across multiple turns and sessions
- **Execute complex workflows** with conditional logic and branching
- **Use tools and APIs** to interact with external systems
- **Implement memory systems** for long-term context retention
- **Coordinate multiple agents** in hierarchical or collaborative patterns

A typical LangGraph agent architecture includes:

```
┌─────────────────────────────────────────┐
│         LangGraph Agent                 │
│                                         │
│  ┌───────────┐      ┌──────────────┐  │
│  │  Memory   │──────│  State Graph │  │
│  │  System   │      │   (Nodes &   │  │
│  └───────────┘      │    Edges)    │  │
│                     └──────────────┘  │
│                            │          │
│  ┌─────────────────────────▼────────┐ │
│  │         Tool Executor            │ │
│  │  (APIs, Databases, Functions)    │ │
│  └──────────────────────────────────┘ │
│                            │          │
│  ┌─────────────────────────▼────────┐ │
│  │      LLM Integration             │ │
│  │  (OpenAI, Anthropic, etc.)       │ │
│  └──────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

Deploying this architecture requires containerization to ensure all dependencies, configurations, and runtime environments remain consistent.

***

## Why Docker for LangGraph Agent Deployment?

Docker containers are the ideal deployment vehicle for AI agents. Here's why:

### Dependency Isolation

LangGraph agents often require specific versions of:
- Python runtime (3.9, 3.10, 3.11)
- LangChain and LangGraph libraries
- Vector database clients (Pinecone, Weaviate, ChromaDB)
- API client libraries for tools and integrations

Docker ensures these dependencies are identical in development, testing, and production environments.

### Reproducible Builds

AI agents evolve rapidly as you iterate on prompts, tools, and workflows. Docker's layer caching means rebuilds are fast, and every build produces a reproducible artifact tagged with version identifiers.

### Platform Portability

Containerized agents can run anywhere:
- Cloud platforms (AWS ECS/EKS, Azure Container Instances, Google Cloud Run)
- Serverless container services (AWS Fargate, Azure Container Apps)
- On-premises Kubernetes clusters
- Developer laptops for local testing

### Resource Management

Containers provide process isolation and resource limits, essential for production agents that make expensive LLM API calls. You can set memory limits, CPU allocations, and enforce timeouts.

***

## GitHub Actions: The CI/CD Platform for AI Agents

GitHub Actions is a powerful automation platform built directly into GitHub repositories. For AI agent deployment, it offers:

- **Native Git integration**: Workflows trigger automatically on commits, pull requests, and releases
- **Matrix builds**: Test agents across multiple Python versions simultaneously
- **Secrets management**: Securely inject API keys and credentials into workflows
- **Artifact storage**: Cache dependencies and store build outputs
- **Marketplace actions**: Reusable components for Docker, cloud deployments, and testing
- **Self-hosted runners**: Run workflows on your own infrastructure for specialized hardware needs

GitHub Actions workflows are defined in YAML files stored in `.github/workflows/`. They consist of:
- **Triggers**: Events that start workflows (push, pull_request, schedule)
- **Jobs**: Collections of steps that run on the same runner
- **Steps**: Individual commands or actions that execute sequentially
- **Actions**: Reusable components from GitHub Marketplace or custom scripts

***

## Building the CI/CD Pipeline: Architecture Overview

Our complete CI/CD pipeline for LangGraph agents includes these stages:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Code      │────▶│  Continuous  │────▶│ Continuous  │
│   Push      │     │ Integration  │     │ Deployment  │
└─────────────┘     └──────────────┘     └─────────────┘
                           │                     │
                    ┌──────▼──────┐       ┌─────▼──────┐
                    │   Testing   │       │   Docker   │
                    │   Linting   │       │   Build    │
                    └─────────────┘       └────────────┘
                                                 │
                                          ┌──────▼──────┐
                                          │   Registry  │
                                          │   Push      │
                                          └─────────────┘
                                                 │
                                          ┌──────▼──────┐
                                          │  Deploy to  │
                                          │  Production │
                                          └─────────────┘
```

**Continuous Integration Stage**:
1. Checkout code from repository
2. Set up Python environment
3. Install dependencies (including LangGraph, LangChain)
4. Run unit tests for agent logic
5. Run integration tests with mock LLM responses
6. Lint code for quality standards
7. Validate environment variables and configurations

**Continuous Deployment Stage**:
1. Build Docker container with optimized layers
2. Tag image with version identifier (commit SHA, semantic version)
3. Push to container registry (Docker Hub, GHCR, ECR)
4. Deploy to target environment (staging, production)
5. Run smoke tests to validate deployment
6. Update monitoring and observability dashboards

***

## Prerequisites: Setting Up Your LangGraph Agent Project

Before implementing CI/CD, ensure your LangGraph agent project is properly structured:

### Project Structure

```
langgraph-agent/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Continuous Integration workflow
│       └── cd.yml              # Continuous Deployment workflow
├── agent/
│   ├── __init__.py
│   ├── graph.py                # LangGraph agent definition
│   ├── tools.py                # Agent tools and functions
│   ├── memory.py               # State and memory management
│   └── config.py               # Configuration and settings
├── tests/
│   ├── test_agent.py           # Unit tests for agent logic
│   ├── test_tools.py           # Tool integration tests
│   └── test_graph.py           # Graph execution tests
├── Dockerfile                  # Container definition
├── docker-compose.yml          # Local development environment
├── requirements.txt            # Python dependencies
├── pyproject.toml              # Project metadata and tool configs
├── .env.example                # Example environment variables
└── README.md                   # Project documentation
```

### Required Files

**requirements.txt** - Pin exact versions for reproducibility:
```txt
langgraph==0.2.0
langchain==0.3.0
langchain-openai==0.2.0
langchain-anthropic==0.2.0
python-dotenv==1.0.0
pydantic==2.5.0
httpx==0.25.0
redis==5.0.0
```

**.env.example** - Document required environment variables:
```bash
# LLM Provider API Keys
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

# Agent Configuration
AGENT_MODEL=gpt-4
AGENT_TEMPERATURE=0.7
MAX_ITERATIONS=10

# Infrastructure
REDIS_URL=redis://localhost:6379
LOG_LEVEL=INFO
```

***

## Step 1: Containerizing Your LangGraph Agent

The foundation of our CI/CD pipeline is a well-optimized Dockerfile. Here's a production-ready example:

### Dockerfile for LangGraph Agent

```dockerfile
# Use official Python slim image for smaller size
FROM python:3.11-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create non-root user for security
RUN useradd -m -u 1000 agent && \
    mkdir -p /app && \
    chown -R agent:agent /app

WORKDIR /app

# Install system dependencies (if needed for your tools)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies first (for layer caching)
COPY --chown=agent:agent requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=agent:agent agent/ ./agent/
COPY --chown=agent:agent tests/ ./tests/

# Switch to non-root user
USER agent

# Expose port for agent API (if serving HTTP)
EXPOSE 8000

# Health check endpoint (customize based on your agent)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run the agent
CMD ["python", "-m", "agent.main"]
```

### Key Dockerfile Optimizations

**Layer Caching**: Dependencies are installed before copying application code. Since `requirements.txt` changes less frequently than source code, Docker reuses cached layers, speeding up builds.

**Security**: Running as non-root user `agent` follows security best practices and prevents container escape vulnerabilities.

**Size Optimization**: Using `python:3.11-slim` instead of full Python image reduces image size by 500+ MB. Cleaning apt cache further minimizes size.

**Health Checks**: Built-in health checks enable orchestrators (Kubernetes, ECS) to automatically restart unhealthy containers.

### Building Locally

Test your Dockerfile locally before CI/CD integration:

```bash
# Build the image
docker build -t langgraph-agent:local .

# Run with environment variables
docker run -e OPENAI_API_KEY=$OPENAI_API_KEY \
           -e AGENT_MODEL=gpt-4 \
           -p 8000:8000 \
           langgraph-agent:local

# Test the agent
curl http://localhost:8000/health
```

***

## Step 2: Continuous Integration Workflow

Create `.github/workflows/ci.yml` to automate testing on every commit:

```yaml
name: Continuous Integration

# Trigger on push to main and all pull requests
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test LangGraph Agent
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: ["3.10", "3.11"]

    steps:
      # Checkout repository code
      - name: Checkout code
        uses: actions/checkout@v4

      # Set up Python environment
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      # Install dependencies
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov pytest-asyncio black ruff

      # Lint code for style and quality
      - name: Lint with ruff
        run: |
          ruff check agent/ tests/

      # Check code formatting
      - name: Check formatting with black
        run: |
          black --check agent/ tests/

      # Run unit tests with coverage
      - name: Run tests
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          pytest tests/ \
            --cov=agent \
            --cov-report=xml \
            --cov-report=term-missing \
            -v

      # Upload coverage to Codecov (optional)
      - name: Upload coverage reports
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-${{ matrix.python-version }}

  # Validate Docker build (don't push yet)
  docker-build-test:
    name: Test Docker Build
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: langgraph-agent:test
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Test container runs
        run: |
          docker run --rm \
            -e OPENAI_API_KEY=test \
            langgraph-agent:test \
            python -c "import agent; print('Container works!')"
```

### CI Workflow Breakdown

**Matrix Testing**: The `strategy.matrix` runs tests across Python 3.10 and 3.11 simultaneously, catching version-specific issues.

**Dependency Caching**: `cache: 'pip'` stores installed packages between runs, reducing install time from 2+ minutes to under 30 seconds.

**Linting and Formatting**: Enforces code quality with `ruff` (fast Python linter) and `black` (code formatter). Failing these checks blocks merging.

**Test Coverage**: `pytest-cov` generates coverage reports showing which code paths are tested. Aim for 80%+ coverage on agent logic.

**Secrets Management**: API keys are stored as GitHub Secrets and injected via `env:` blocks. Never commit keys to repositories.

**Docker Build Validation**: Ensures the Dockerfile builds successfully before deployment. Uses GitHub Actions cache to speed up subsequent builds.

***

## Step 3: Continuous Deployment Workflow

Create `.github/workflows/cd.yml` to automate container builds and deployments:

```yaml
name: Continuous Deployment

# Trigger on tags and successful merges to main
on:
  push:
    branches: [main]
    tags:
      - 'v*.*.*'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    name: Build and Push Docker Image
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Login to GitHub Container Registry
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      # Extract metadata (tags, labels) for Docker
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-

      # Build and push Docker image
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64

      # Sign container image with cosign (optional security)
      - name: Sign container image
        env:
          COSIGN_EXPERIMENTAL: 1
        run: |
          echo "${{ steps.meta.outputs.tags }}" | xargs -I {} cosign sign {}@${{ steps.build.outputs.digest }}

  deploy-staging:
    name: Deploy to Staging
    needs: build-and-push
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.yourdomain.com

    steps:
      - name: Deploy to staging environment
        run: |
          # Example: Deploy to AWS ECS
          aws ecs update-service \
            --cluster langgraph-staging \
            --service agent-service \
            --force-new-deployment

      - name: Run smoke tests
        run: |
          # Wait for deployment
          sleep 30
          # Test agent health endpoint
          curl -f https://staging.yourdomain.com/health || exit 1

  deploy-production:
    name: Deploy to Production
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://yourdomain.com
    # Only deploy on version tags
    if: startsWith(github.ref, 'refs/tags/v')

    steps:
      - name: Deploy to production
        run: |
          # Example: Deploy to AWS ECS with blue/green deployment
          aws ecs update-service \
            --cluster langgraph-production \
            --service agent-service \
            --force-new-deployment \
            --deployment-configuration "deploymentCircuitBreaker={enable=true,rollback=true}"

      - name: Verify production deployment
        run: |
          # Comprehensive health checks
          curl -f https://yourdomain.com/health || exit 1
          # Test agent functionality
          curl -X POST https://yourdomain.com/invoke \
            -H "Content-Type: application/json" \
            -d '{"input": "test query"}' || exit 1
```

### CD Workflow Key Features

**Multi-Registry Support**: The example uses GitHub Container Registry (GHCR), but you can easily switch to Docker Hub, AWS ECR, or Azure Container Registry by changing login credentials.

**Semantic Versioning**: The `docker/metadata-action` automatically generates tags from Git tags (`v1.0.0` becomes `1.0.0`, `1.0`, and `latest`).

**Multi-Architecture Builds**: `platforms: linux/amd64,linux/arm64` creates images for both x86 and ARM processors (important for AWS Graviton, Apple Silicon).

**Environment Protection**: GitHub Environments allow you to require approvals before production deployments and set secrets per environment.

**Automated Rollbacks**: AWS ECS deployment circuit breaker automatically rolls back failed deployments.

***

## Step 4: Container Registry Options

Choose the right registry for your deployment target:

### GitHub Container Registry (GHCR)

**Best for**: Open source projects and teams already using GitHub.

**Advantages**:
- Free for public repositories
- Seamless integration with GitHub Actions (`GITHUB_TOKEN` authentication)
- Automatic image scanning for vulnerabilities
- Fine-grained access control with GitHub teams

**Setup**:
```yaml
- name: Log in to GHCR
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

### Docker Hub

**Best for**: Public container distribution and broad compatibility.

**Advantages**:
- Largest container registry with billions of pulls
- Excellent CDN for fast image pulls globally
- Free tier includes unlimited public repositories

**Setup**:
```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

### AWS Elastic Container Registry (ECR)

**Best for**: Deploying to AWS services (ECS, EKS, Lambda).

**Advantages**:
- Native AWS integration with IAM authentication
- Automatic image scanning and vulnerability detection
- Lifecycle policies for automatic cleanup of old images
- Low latency for pulls from AWS compute services

**Setup**:
```yaml
- name: Log in to AWS ECR
  uses: aws-actions/amazon-ecr-login@v2
  with:
    registry-type: private

- name: Build and push to ECR
  run: |
    docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
    docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

***

## Step 5: Deployment Strategies for LangGraph Agents

### Option 1: AWS ECS (Elastic Container Service)

**Ideal for**: Production agents requiring auto-scaling and load balancing.

**Deployment pattern**:
```yaml
- name: Deploy to ECS
  run: |
    # Register new task definition
    aws ecs register-task-definition \
      --cli-input-json file://task-definition.json

    # Update service with new task definition
    aws ecs update-service \
      --cluster langgraph-cluster \
      --service agent-service \
      --task-definition langgraph-agent:${{ github.sha }}
```

**Benefits**:
- Automatic load balancing across multiple agent instances
- Integration with AWS Application Load Balancer
- CloudWatch logging and monitoring
- Auto-scaling based on CPU, memory, or custom metrics

### Option 2: AWS Lambda with Container Images

**Ideal for**: Sporadic agent invocations with variable load.

**Deployment pattern**:
```yaml
- name: Deploy to Lambda
  run: |
    aws lambda update-function-code \
      --function-name langgraph-agent \
      --image-uri $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

**Benefits**:
- Pay-per-invocation pricing (no idle costs)
- Automatic scaling to handle spikes
- 10GB container image support (enough for LangGraph + models)
- Up to 15 minutes execution time per invocation

### Option 3: Google Cloud Run

**Ideal for**: Simple, fully managed container deployment.

**Deployment pattern**:
```yaml
- name: Deploy to Cloud Run
  uses: google-github-actions/deploy-cloudrun@v2
  with:
    service: langgraph-agent
    image: gcr.io/${{ secrets.GCP_PROJECT }}/langgraph-agent:${{ github.sha }}
    region: us-central1
```

**Benefits**:
- Serverless with automatic HTTPS endpoints
- Scale to zero when idle (zero cost)
- Built-in traffic splitting for canary deployments
- Simple pricing based on request duration

### Option 4: Kubernetes (EKS, GKE, AKS)

**Ideal for**: Complex multi-agent systems with advanced orchestration needs.

**Deployment pattern**:
```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl set image deployment/langgraph-agent \
      agent=$REGISTRY/$IMAGE_NAME:${{ github.sha }} \
      --namespace=agents
    kubectl rollout status deployment/langgraph-agent -n agents
```

**Benefits**:
- Advanced deployment strategies (blue/green, canary, rolling)
- Service mesh integration (Istio, Linkerd)
- Horizontal pod autoscaling
- Multi-tenant isolation for multiple agents

***

## Step 6: Environment Variables and Secrets Management

LangGraph agents require secure handling of API keys, database credentials, and configuration:

### GitHub Secrets

Store sensitive values as repository secrets:

1. Go to **Settings → Secrets and variables → Actions**
2. Add secrets:
   - `OPENAI_API_KEY`
   - `ANTHROPIC_API_KEY`
   - `DATABASE_URL`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Injecting Secrets in Workflows

```yaml
- name: Deploy with secrets
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  run: |
    docker run -e OPENAI_API_KEY -e ANTHROPIC_API_KEY \
      langgraph-agent:latest
```

### Cloud-Native Secrets Management

For production deployments, use cloud provider secret managers:

**AWS Secrets Manager**:
```python
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# In your agent code
secrets = get_secret('langgraph-agent-secrets')
openai_key = secrets['OPENAI_API_KEY']
```

**Environment-based configuration**:
```python
# agent/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    openai_api_key: str
    anthropic_api_key: str
    agent_model: str = "gpt-4"
    max_iterations: int = 10

    class Config:
        env_file = ".env"

settings = Settings()
```

***

## Step 7: Testing Strategies for AI Agents

AI agents require specialized testing approaches:

### Unit Tests for Agent Logic

```python
# tests/test_graph.py
import pytest
from agent.graph import create_agent_graph
from langchain_core.messages import HumanMessage

def test_agent_graph_structure():
    """Test that the agent graph is properly constructed."""
    graph = create_agent_graph()

    # Verify nodes exist
    assert "agent" in graph.nodes
    assert "tools" in graph.nodes

    # Verify edges
    assert ("agent", "tools") in graph.edges

@pytest.mark.asyncio
async def test_agent_simple_query():
    """Test agent handles basic query."""
    graph = create_agent_graph()

    result = await graph.ainvoke({
        "messages": [HumanMessage(content="What is 2+2?")]
    })

    assert "4" in result["messages"][-1].content
```

### Integration Tests with Mock LLMs

Avoid expensive API calls in tests:

```python
# tests/test_agent.py
from unittest.mock import patch
from langchain_core.messages import AIMessage

@patch('agent.graph.ChatOpenAI')
def test_agent_with_mock_llm(mock_llm):
    """Test agent with mocked LLM responses."""
    # Mock the LLM response
    mock_llm.return_value.invoke.return_value = AIMessage(
        content="The weather is sunny."
    )

    graph = create_agent_graph()
    result = graph.invoke({
        "messages": [HumanMessage(content="What's the weather?")]
    })

    assert "sunny" in result["messages"][-1].content.lower()
```

### Smoke Tests for Deployments

Verify deployed agents work correctly:

```bash
#!/bin/bash
# scripts/smoke-test.sh

AGENT_URL=$1

echo "Testing health endpoint..."
curl -f "$AGENT_URL/health" || exit 1

echo "Testing agent invocation..."
RESPONSE=$(curl -s -X POST "$AGENT_URL/invoke" \
  -H "Content-Type: application/json" \
  -d '{"input": "What is LangGraph?"}')

echo "Response: $RESPONSE"

# Check response contains expected content
echo "$RESPONSE" | grep -q "LangGraph" || exit 1

echo "Smoke tests passed!"
```

***

## Step 8: Monitoring and Observability

Production AI agents require comprehensive monitoring:

### LangSmith Integration

[LangSmith](https://smith.langchain.com/) provides specialized observability for LangChain/LangGraph agents:

```python
# agent/config.py
import os

# Enable LangSmith tracing
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = os.getenv("LANGSMITH_API_KEY")
os.environ["LANGCHAIN_PROJECT"] = "langgraph-production"
```

**LangSmith captures**:
- Complete trace of agent execution (every LLM call, tool use, decision)
- Token usage and costs per request
- Latency breakdowns showing bottlenecks
- Input/output pairs for debugging
- Error tracking and stack traces

### Application Performance Monitoring

Integrate APM tools for infrastructure metrics:

**Datadog**:
```python
from ddtrace import tracer
from ddtrace.contrib.langchain import patch

patch()

@tracer.wrap()
async def invoke_agent(input_text):
    # Automatically traced
    return await agent.ainvoke({"messages": [HumanMessage(content=input_text)]})
```

**New Relic**:
```python
import newrelic.agent

@newrelic.agent.background_task()
def process_agent_request(request):
    # Automatically tracked in New Relic
    return agent.invoke(request)
```

### Custom Metrics with Prometheus

Track agent-specific metrics:

```python
from prometheus_client import Counter, Histogram, start_http_server

# Define metrics
agent_invocations = Counter('agent_invocations_total', 'Total agent invocations')
agent_latency = Histogram('agent_latency_seconds', 'Agent response latency')
agent_errors = Counter('agent_errors_total', 'Total agent errors', ['error_type'])

@agent_latency.time()
def invoke_agent(input_data):
    agent_invocations.inc()
    try:
        result = agent.invoke(input_data)
        return result
    except Exception as e:
        agent_errors.labels(error_type=type(e).__name__).inc()
        raise

# Start metrics server
start_http_server(8001)
```

***

## Best Practices for LangGraph CI/CD

### 1. Version Control Everything

- **Commit prompts**: Store all prompt templates in version control
- **Track configurations**: Use `.env.example` to document required variables
- **Pin dependencies**: Use exact versions in `requirements.txt` for reproducibility

### 2. Implement Gradual Rollouts

- **Canary deployments**: Route 5% of traffic to new version initially
- **Blue/green deployments**: Maintain two production environments for instant rollback
- **Feature flags**: Use tools like LaunchDarkly to enable features progressively

### 3. Optimize Docker Images

- **Multi-stage builds**: Separate build and runtime dependencies
- **Layer ordering**: Put frequently changing code last for cache efficiency
- **Security scanning**: Use `trivy` or `snyk` to scan for vulnerabilities

```dockerfile
# Multi-stage build example
FROM python:3.11-slim as builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY agent/ /app/agent/
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "-m", "agent.main"]
```

### 4. Cost Optimization

- **Cache LLM responses**: Use Redis/Postgres for caching identical queries
- **Implement rate limiting**: Prevent runaway token costs from bugs
- **Monitor spend**: Set up alerts when daily LLM costs exceed thresholds

### 5. Security Hardening

- **Scan containers**: Automated vulnerability scanning in CI
- **Least privilege**: Grant minimal IAM permissions to deployed agents
- **Secrets rotation**: Regularly rotate API keys and credentials
- **Input validation**: Sanitize user inputs to prevent prompt injection

***

## Advanced: Multi-Environment Deployment Strategy

Production-grade AI agent deployments use multiple environments:

```
Development → Staging → Production
     ↓            ↓          ↓
  Feature    Integration   Live
   Branch     Testing     Traffic
```

### Environment Configuration

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    strategy:
      matrix:
        environment:
          - name: staging
            cluster: langgraph-staging
            replicas: 2
            model: gpt-4-turbo
          - name: production
            cluster: langgraph-production
            replicas: 10
            model: gpt-4

    steps:
      - name: Deploy to ${{ matrix.environment.name }}
        run: |
          kubectl set image deployment/langgraph-agent \
            agent=$IMAGE:$TAG \
            --namespace=${{ matrix.environment.name }}

          kubectl set env deployment/langgraph-agent \
            AGENT_MODEL=${{ matrix.environment.model }} \
            REPLICAS=${{ matrix.environment.replicas }} \
            --namespace=${{ matrix.environment.name }}
```

***

## Troubleshooting Common CI/CD Issues

### Issue: Docker Build Fails with Memory Errors

**Solution**: Increase Docker memory allocation or use multi-stage builds to reduce image size.

```yaml
- name: Build with increased resources
  uses: docker/build-push-action@v5
  with:
    context: .
    build-args: |
      BUILDKIT_INLINE_CACHE=1
    platforms: linux/amd64
```

### Issue: Tests Flaky Due to LLM API Timeouts

**Solution**: Use mocks in unit tests, increase timeouts in integration tests:

```python
@pytest.mark.timeout(60)  # 60 second timeout
@pytest.mark.flaky(reruns=3)  # Retry up to 3 times
async def test_agent_with_real_llm():
    # Test with actual LLM
    pass
```

### Issue: Container Registry Rate Limits

**Solution**: Authenticate to registries and use registry mirrors:

```yaml
- name: Authenticate to registries
  run: |
    echo "${{ secrets.DOCKERHUB_TOKEN }}" | docker login -u ${{ secrets.DOCKERHUB_USERNAME }} --password-stdin
    echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```

### Issue: Deployment Rollbacks Needed

**Solution**: Tag images with commit SHA for easy rollback:

```bash
# Rollback to previous version
kubectl set image deployment/langgraph-agent \
  agent=$REGISTRY/$IMAGE:$PREVIOUS_SHA

# Or use Kubernetes rollout undo
kubectl rollout undo deployment/langgraph-agent
```

***

## Conclusion: Production-Ready AI Agent Deployment

Implementing CI/CD for LangGraph agents transforms ad-hoc deployments into reliable, automated pipelines. The architecture we've built provides:

- **Automated testing** catching bugs before production
- **Reproducible deployments** with Docker containerization
- **Version control** of agent code, prompts, and configurations
- **Zero-downtime deployments** with rolling updates and health checks
- **Scalability** from development to production-scale traffic
- **Cost optimization** through caching, monitoring, and resource management

The patterns demonstrated here extend beyond LangGraph to any AI agent framework. Whether you're deploying CrewAI, AutoGPT, or custom agent architectures, the principles of containerization, automated testing, and gradual rollouts remain essential.

### Key Takeaways

1. **Containerize everything**: Docker ensures consistency across all environments
2. **Automate testing**: Mock LLMs in tests to avoid expensive API calls
3. **Use semantic versioning**: Tag images with versions for easy rollback
4. **Monitor extensively**: LangSmith + APM tools provide complete observability
5. **Deploy gradually**: Canary and blue/green deployments minimize risk
6. **Secure by default**: Never commit secrets; use cloud secret managers

### Getting Started Checklist

- [ ] Structure your LangGraph agent project with proper separation of concerns
- [ ] Create a production-ready Dockerfile with security best practices
- [ ] Set up GitHub Actions workflows for CI (testing) and CD (deployment)
- [ ] Configure container registry (GHCR, Docker Hub, or ECR)
- [ ] Store secrets in GitHub Secrets and cloud secret managers
- [ ] Implement comprehensive testing (unit, integration, smoke tests)
- [ ] Set up monitoring with LangSmith and APM tools
- [ ] Deploy to staging environment and validate
- [ ] Create deployment runbooks for rollbacks and incident response
- [ ] Gradually roll out to production with traffic splitting

### Resources and Further Reading

- **[LangGraph Documentation](https://langchain-ai.github.io/langgraph/)** — Official LangGraph framework docs
- **[GitHub Actions Documentation](https://docs.github.com/actions)** — Complete guide to GitHub Actions
- **[Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)** — Dockerfile optimization and security
- **[LangSmith Tracing](https://docs.smith.langchain.com/)** — Agent observability and monitoring
- **[AWS ECS Deployment Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/)** — Container orchestration on AWS

***

*Building production AI agents? Have questions about implementing CI/CD for LangGraph or other agent frameworks? Reach out to discuss deployment strategies, monitoring approaches, and scaling challenges.*
