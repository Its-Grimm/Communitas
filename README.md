<h1 align="center">
  <br>
  <a href="https://github.com/Its-Grimm/Communitas"><img src="./icons/Communitas.png" alt="Communitas" width="200"></a>
  <br>
  Communitas
  <br>
</h1>

<h4 align="center">A simple, configurable Linux journaling + Mastodon CLI tool.</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#download">Download</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

---

## Key Features

* Terminal-based journaling workflow
  - Quickly create, edit, and view journal entries directly from your CLI
* Mastodon integration
  - Post, edit, and delete statuses from your journal entries
* Write + Post workflow
  - Create an entry and publish it instantly in one command
* Local journaling system
  - Entries stored in a structured year/month directory hierarchy
* Configurable editor support
  - Uses `vim` by default (or any editor you define)
* Entry limits for safety
  - Prevents overly large or empty journal entries
* Remote + local sync options
  - Choose whether deletions and edits affect local files
* Markdown-based entries
  - Clean `.md` format for portability and readability
* Lightweight Bash implementation
  - No heavy dependencies beyond common CLI tools

---

## How To Use

To use Communitas, ensure you have the required dependencies installed and your `.env` file configured.

From your command line:

```bash
# Make script executable
chmod +x cmm.sh

# Create a new journal entry
./cmm.sh -w

# Write and immediately post to Mastodon
./cmm.sh -wp

# Post latest entry
./cmm.sh -p

# View latest entry
./cmm.sh -v l

# Edit latest entry
./cmm.sh -e l

# Edit latest Mastodon post
./cmm.sh -ep l

# Delete latest entry
./cmm.sh -d l

# Delete latest Mastodon post (and optionally local copy)
./cmm.sh -dp l 
```

---

## Download

Clone the repository and start using Communitas immediately:
```
git clone https://github.com/Its-Grimm/Communitas
cd Communitas
chmod +x cmm.sh
```

---

## Configuration

Communitas is configured via a ```.env``` file and optional local config settings.

--- 

## Required .env
```
API_KEY=your_mastodon_api_key

ACCT_ID=your_account_id
```

--- 

## Key Settings (.config)
* default_location
  - Base directory for journal storage
* date_style
  - Controls directory/file naming format
* time_style
  - Controls timestamp formatting in filenames
* platforms
  - Active posting targets (currently Mastodon)
* editor
  - Default CLI editor (vim, nvim, nano, etc.)
* effect_local_when_post
  - If true: local files are modified/deleted when posting actions occur
  - If false: local and remote content are decoupled

---

## Requirements

You need the following installed:

* bash
* curl
* jq
* vim (or configured editor)
* Mastodon account + API access

---

## Credits

Communitas is built using standard Unix tools and the Mastodon API.

* <a href='https://docs.joinmastodon.org/api/'> Mastodon API </a>
* <a href='https://stedolan.github.io/jq/'> jq </a>
* <a href='https://curl.se/'> curl </a>

---

## Related

Extend this tool with support for other platforms (Twitter/X, Pixelfed, etc.)
Future idea: encryption for private journal entries
Potential GUI wrapper for desktop usage

---

## License

MIT