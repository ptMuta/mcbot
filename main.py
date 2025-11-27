import os
import logging
import discord
from discord import app_commands
from commands import load_commands

BOT_TOKEN = os.environ['DISCORD_BOT_TOKEN']

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('bot.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('main')

intents = discord.Intents.default()
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)
load_commands(tree)


@client.event
async def on_ready():
    await tree.sync()
    logger.info(f'Bot ready: {client.user}')


if __name__ == '__main__':
    client.run(BOT_TOKEN)
