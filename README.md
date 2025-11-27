# Minecraft Discord Bot

## Setup

### 1. Install Bot

```bash
bash ./install.sh
```

### 2. Enable RCON on Minecraft Server

Edit your `server.properties`:
```properties
enable-rcon=true
rcon.port=25575
rcon.password=your_password_here
```

### 3. Invite the Bot to Your Server

Use the OAuth2 URL generator in Discord Developer Portal:
- Scopes: `bot`, `applications.commands`
- Bot Permissions: As needed (basic permissions are sufficient)

### 4. Run the Bot

#### Development
```bash
export DISCORD_BOT_TOKEN="your_token"
export RCON_PASSWORD="your_password"
python bot.py
```

#### Production
```bash
sudo ./install.sh
```

The installer will:
- Create a dedicated `mcbot` service user
- Install files to `/opt/mcbot`
- Set up a Python virtual environment
- Install dependencies
- Configure systemd service

After installation, edit the service configuration:
```bash
sudo systemctl edit --full mcbot.service
```

Then start the service:
```bash
sudo systemctl start mcbot
sudo systemctl status mcbot
```

View logs:
```bash
sudo journalctl -u mcbot -f
```

## Adding New Commands

Create a new Python file in the `commands/` directory with a `setup(group)` function:

```python
import discord
from discord import app_commands

async def my_command(interaction: discord.Interaction):
    embed = discord.Embed(
        title="My Command",
        description="Command executed successfully.",
        color=discord.Color.green()
    )
    await interaction.response.send_message(embed=embed)

def setup(group: app_commands.Group):
    @group.command(name='mycommand', description='My custom command')
    async def cmd(interaction: discord.Interaction):
        await my_command(interaction)
```

The command will be automatically discovered and registered as `/mcbot mycommand` on bot startup.
