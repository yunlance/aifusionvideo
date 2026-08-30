<p align="center">
  <img src="assets/banner-design.png" alt="AI Fusion Video Banner" width="920" />
</p>

<p align="center">
  <a href="README.md">简体中文</a> | <strong>English</strong>
</p>

<h1 align="center">AI Fusion Video</h1>

<p align="center">An Agent-driven video creation platform</p>

<p align="center">
  <a href="https://github.com/yunlance/aifusionvideo/releases"><img src="https://img.shields.io/github/v/release/yunlance/aifusionvideo?display_name=tag" alt="GitHub Release" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/yunlance/aifusionvideo" alt="MIT License" /></a>
  <img src="https://img.shields.io/badge/Java-21-ED8B00" alt="Java 21" />
  <img src="https://img.shields.io/badge/Next.js-16-000000" alt="Next.js 16" />
</p>

<p align="center">
  <img src="https://api.star-history.com/svg?repos=yunlance/aifusionvideo&type=Date" alt="GitHub Star History" width="920" />
</p>

<table align="center" style="margin: 0 auto; display: table;">
  <tr>
    <td align="center">
      <b>Want to collaborate or give feedback? Open a <a href="https://github.com/yunlance/aifusionvideo/issues">GitHub Issue</a>.</b>
    </td>
  </tr>
</table>

<table align="center">
  <thead>
    <tr>
      <th align="center">Contact the author</th>
      <th align="center">Join the community</th>
      <th align="center">Buy the author a coffee</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33%">
        <a href="https://github.com/yunlance/aifusionvideo/issues">Open a GitHub Issue</a>
      </td>
      <td align="center" width="33%">
        <a href="https://github.com/yunlance/aifusionvideo/discussions">GitHub Discussions</a>
      </td>
      <td align="center" width="33%">
        <a href="https://github.com/yunlance/aifusionvideo">Star this project ⭐</a>
      </td>
    </tr>
  </tbody>
</table>

<p align="center">
  <sub><b>For support and discussions, please use <a href="https://github.com/yunlance/aifusionvideo/discussions">GitHub Discussions</a>.</b></sub>
</p>

<hr/>

AI Fusion Video is an Agent-driven platform for video creators. It brings projects, scripts, storyboards, assets, and image and video generation into one workspace. Creators can organize scripts by episode and scene, break them down into storyboards, refine individual shots, and generate and manage the assets needed for production.

This repository includes a Java backend, a Next.js frontend, and Docker Compose deployment files. After deployment, open the site and sign in as `admin`. Cloud models use the built-in Yunlan Chuan gateway, with local ComfyUI as an optional generation channel.

## Features

| Area | What you can do |
| --- | --- |
| Projects and teams | Manage creative projects, project members, and collaboration roles |
| Script writing | Organize scripts by episode and scene, and provide project context to an Agent |
| Storyboarding | Build storyboards from scripts and edit shot content, reference assets, and generation results |
| Image and video generation | Generate images and video from text or reference assets while tracking background job progress |
| Asset management | Organize project assets and reusable image and video resources |
| Agent workspace | Use streaming chat, multimodal context, tool permissions, Skills, MCP, and sub-Agents |
| Models and storage | Enter a Yunlan Chuan API key in Settings, or connect a local ComfyUI workflow; media can use local disk or object storage |
| System administration | Manage users and roles, reset passwords, and check for updates |

### Agents and tools

The built-in Agent workspace can hold ongoing conversations grounded in project content, accept multimodal inputs such as images, video, audio, and files, and display reasoning, tool calls, and task status in the interface.

Agents run on AgentScope with support for Skills, MCP, and sub-Agents. Conversations and run state are persisted, while model capabilities and tool permissions can be configured per conversation for multi-step creative work.

### Model and generation protocols

Enter models and API keys in Settings; they are not stored in source code. Cloud chat, image, and video calls go through the built-in **Yunlan Chuan** gateway. Local **ComfyUI** workflows can be configured as a second generation channel. The UI does not allow adding third-party cloud providers such as OpenAI, Anthropic, or Gemini.

After startup, open `Settings > AI Models` and fill in the Yunlan Chuan API key. Available models depend on your gateway account and permissions.

### Storage

Media assets can be stored on local disk or in an S3-compatible object store. Agent workspaces can likewise use the database, local disk, or object storage, making the setup suitable for local development, single-server deployments, and cloud environments.

## UI demos

https://github.com/user-attachments/assets/fe71cbb8-f9d9-4351-9a4c-cb8a0a6af7ba

https://github.com/user-attachments/assets/24d9443b-e463-405c-8ada-108236b4d6c2

https://github.com/user-attachments/assets/2f1de26c-5cd5-4be3-ad2e-81be2edd6956

https://github.com/user-attachments/assets/acd26ede-8b77-48c0-91dc-c80c5ed7ceca

https://github.com/user-attachments/assets/8a8ce3cf-4bf8-4f76-ad7c-0af373d16a5b

https://github.com/user-attachments/assets/be99d4c1-dc09-4616-8fba-06cb959c84c8

## Tech stack

| Layer | Technology |
| --- | --- |
| Frontend | Next.js 16, React 19, TypeScript, Tailwind CSS 4, Base UI / Shadcn, Zustand |
| Backend | Java 21, Spring Boot 3.5, Spring Security, Spring AI, AgentScope, MyBatis-Plus |
| Data | MySQL 8, Redis, Flyway |
| Media | FFmpeg, FFprobe, local storage or an S3-compatible object store |
| Deployment | Docker Compose, Nginx |

## Quick Deploy

### Docker Compose

Docker Compose is recommended for deployment. With Docker Engine and Docker Compose installed, run:

```bash
git clone https://github.com/yunlance/aifusionvideo.git
cd aifusionvideo

cp .env.example .env

docker compose up -d
```

This command pulls the prebuilt images and starts MySQL, Redis, the backend, the frontend, and Nginx.

To customize ports or passwords, edit the root `.env` file. Git ignores this file, so later project updates do not require changes to `docker-compose.yml`. Set `ADMIN_PASSWORD` in `.env` before deployment.

When startup completes, open <http://localhost:5858> and sign in as `admin` with the `ADMIN_PASSWORD` from `.env`. To check the services or follow the backend logs, run:

```bash
docker compose ps
docker compose logs -f backend
```

Nginx provides a single entry point and forwards `/api/**` and `/media/**` requests to the backend. Before a public deployment, update the default database password, Redis password, and `ADMIN_PASSWORD` in `.env`.

### Build images locally

To build the frontend and backend images from the current source, run:

```bash
docker compose -f docker-compose.build.yml up -d --build
```

### Separate frontend and backend deployment

If the frontend and backend use different public domains, configure the following values in `.env`:

```env
PUBLIC_API_URL=https://api.example.com
CORS_ALLOWED_ORIGIN_PATTERNS=https://app.example.com
FRONTEND_PORT=5000
BACKEND_PORT=15858
```

Set `PUBLIC_API_URL` to the backend root URL without a trailing `/api`. The backend allows cross-origin requests globally by default. In production, restrict `CORS_ALLOWED_ORIGIN_PATTERNS` to the actual frontend origins as shown above; separate multiple origins with commas.

Use the prebuilt images:

```bash
docker compose -f docker-compose.yml -f docker-compose.separated.yml up -d
```

Build the images from source:

```bash
docker compose -f docker-compose.build.yml -f docker-compose.separated.yml up -d --build
```

Separate frontend and backend deployment leaves the repository's built-in Nginx service disabled. Configure an HTTPS reverse proxy for each service, then open `Settings > General` and confirm the site public URL and backend resource public URL.

## Source development

### Requirements

- JDK 21
- Node.js 20 and pnpm 10
- Docker for local MySQL and Redis
- FFmpeg and FFprobe for video composition and media inspection

### Start middleware and backend

```bash
cd yunlan-video-server
docker compose -f docker-compose-middleware.yml up -d
./mvnw spring-boot:run
```

Windows users can run `.\mvnw.cmd spring-boot:run`.

The backend uses the `local` profile by default. Its settings live in `yunlan-video-server/src/main/resources/application-local.yaml`. If FFmpeg and FFprobe are not in their default locations, set `VIDEO_COMPOSE_FFMPEG_PATH` and `VIDEO_COMPOSE_FFPROBE_PATH` to the correct binaries.

### Start the frontend

Open another terminal at the repository root:

```bash
cd yunlan-video-webui
pnpm install
pnpm dev
```

The Next.js development server reads `yunlan-video-webui/.env.development` and proxies `/api/**` and `/media/**` to `http://localhost:15858`. If the backend listens on another port, override the proxy target in `.env.local`:

```env
DEV_BACKEND_URL=http://localhost:15858
```

### Local addresses

| Service | Address |
| --- | --- |
| Frontend | <http://localhost:5000> |
| Backend | <http://localhost:15858> |
| Swagger UI | <http://localhost:15858/swagger-ui.html> |
| MySQL | `localhost:53306` |
| Redis | `localhost:56379` |

## Configuration

### Docker environment variables

Docker Compose automatically reads `.env` from the repository root. Each startup mode uses the following configuration:

| Deployment mode | Compose files | Variables to review |
| --- | --- | --- |
| Default unified gateway | `docker-compose.yml` | Review the MySQL root password, Redis password, and `ADMIN_PASSWORD`; application credentials are optional; change `MYSQL_DATABASE`, `APP_PORT`, `JAVA_OPTS`, or the CORS allowlist only when needed; keep `PUBLIC_API_URL` empty |
| Separate frontend and backend | Base Compose file + `docker-compose.separated.yml` | Set `PUBLIC_API_URL`; setting `CORS_ALLOWED_ORIGIN_PATTERNS` is recommended in production; change `FRONTEND_PORT` and `BACKEND_PORT` when needed; `APP_PORT` is not used |

Change the MySQL root password, Redis password, and `ADMIN_PASSWORD` before any public deployment. If a MySQL application account is enabled, give it a separate password as well. `FRONTEND_PORT`, `BACKEND_PORT`, and `PUBLIC_API_URL` only take effect when `docker-compose.separated.yml` is included; `CORS_ALLOWED_ORIGIN_PATTERNS` applies to every deployment mode.

| Variable | Default | Purpose |
| --- | --- | --- |
| `MYSQL_ROOT_PASSWORD` | `123456` | MySQL `root` administration password; it must be changed before public deployment |
| `REDIS_PASSWORD` | `123456` | Redis access password; it must be changed before public deployment |
| `MYSQL_DATABASE` | `aifusionvideo` | MySQL database name; normally does not need to be changed |
| `APP_PORT` | `5858` | Default unified gateway port; open `http://localhost:5858` after startup |
| `FRONTEND_PORT` | `5000` | Exposed frontend port for separate frontend and backend deployment |
| `BACKEND_PORT` | `15858` | Exposed backend port for separate frontend and backend deployment |
| `PUBLIC_API_URL` | Empty | Public backend root URL for separate deployment; do not include `/api` |
| `CORS_ALLOWED_ORIGIN_PATTERNS` | `*` | Browser origins allowed to call the backend; `*` allows all origins. Use explicit production origins and separate multiple values with commas |
| `JAVA_OPTS` | `-Xms512m -Xmx1024m` | Backend JVM options; normally do not need to be changed |
| `MYSQL_USERNAME` | Empty | Optional MySQL application account; must not be set to `root`; leaving it empty preserves root access |
| `MYSQL_PASSWORD` | Empty | Optional MySQL application password; must be configured together with `MYSQL_USERNAME` |
| `ADMIN_PASSWORD` | Empty | Password for the `admin` account created on startup; set it before a public deployment. Leaving it empty uses a built-in default hash |

Keep `PUBLIC_API_URL` empty when you use the unified gateway. `CORS_ALLOWED_ORIGIN_PATTERNS` may remain `*` or be restricted to the site's actual origin.

`MYSQL_USERNAME` and `MYSQL_PASSWORD` must either both be set or both remain empty. When `.env.example` is copied as-is, both variables are empty and the backend continues using `root` with `MYSQL_ROOT_PASSWORD`, matching the historical default. For a new database, setting both variables before startup makes MySQL create the regular account and grant it access to `MYSQL_DATABASE`. To move an existing database to a regular account, create and grant the user in MySQL before setting these variables; changing `.env` does not modify existing database accounts.

The MySQL port is published to `127.0.0.1:53306` by default, so local tools such as Navicat can connect directly. The Redis port is not published by default; to expose it, uncomment the corresponding `ports` entry in the Compose file (for example, `127.0.0.1:46379`).

### Public resource URLs

Cloud image and video models generally cannot fetch reference assets from `localhost` or a private network address. Use public object storage or securely expose the backend resource endpoint, then save the corresponding public URL under `Settings > General`.

The site public URL is used for password reset emails and page links, while the backend resource public URL is used for media links and Agent references. The two settings may point to different domains.

## Project layout

```text
.
├─ yunlan-video-server/       Java backend, Flyway migrations, and backend tests
├─ yunlan-video-webui/   Next.js frontend
├─ docker/                Nginx configuration
├─ docker-compose.yml           Pulls the prebuilt images
├─ docker-compose.build.yml     Local source build deployment
└─ docker-compose.separated.yml Separate frontend/backend override
```

## Checks and tests

Backend:

```bash
cd yunlan-video-server
./mvnw test
./mvnw -Dtest=FlywayMigrationNamingTests test
./mvnw -Pagentscope-integration verify
```

Frontend:

```bash
cd yunlan-video-webui
pnpm lint
pnpm build
```

Flyway migrations live in `yunlan-video-server/src/main/resources/db/migration/`. See the [Flyway migration rules](yunlan-video-server/src/main/resources/db/migration/README.md) for version names, baselines, and migration history constraints.

## Contributing

Issue reports, feature suggestions, and code improvements are welcome. For features or architectural changes with a broad impact, please open an Issue to describe the proposal and confirm the direction before starting development.

### Development workflow

1. Fork this repository and clone your fork, then add this repository as `upstream`:

   ```bash
   git clone https://github.com/YOUR-USERNAME/aifusionvideo.git
   cd aifusionvideo
   git remote add upstream https://github.com/yunlance/aifusionvideo.git
   ```

2. Create a feature branch from the latest `main`. Do not make changes directly on `main` or a version development branch:

   ```bash
   git fetch upstream
   git checkout main
   git pull --ff-only upstream main
   git checkout -b feat/your-change
   ```

   Use a prefix such as `feat/`, `fix/`, or `docs/`, followed by a short description of the change.

3. After completing the change, run the checks relevant to your work:

   ```bash
   # Backend
   cd yunlan-video-server
   ./mvnw test

   # Frontend
   cd ../yunlan-video-webui
   pnpm lint
   pnpm build
   ```

4. Commit and push your branch:

   ```bash
   git add path/to/changed-file
   git commit -m "feat: describe your change"
   git push -u origin feat/your-change
   ```

5. When opening a Pull Request, set this repository's `main` branch as the target.

Before submitting, make sure the change has a clear scope and does not include secrets, credentials, or local environment files. Add or update tests and documentation when behavior changes.

## Acknowledgements

- Thanks to the [LinuxDo](https://linux.do) community for supporting the project
- Thanks to [waoowaoo](https://github.com/saturndec/waoowaoo) for the script editor design reference

## License

[MIT License](LICENSE)

<p align="center">
  <sub>Built by <a href="https://github.com/yunlance">yunlance</a></sub>
</p>
