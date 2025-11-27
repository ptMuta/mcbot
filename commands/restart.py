import os
import logging
import discord
from discord import app_commands
from mcrcon import MCRcon

logger = logging.getLogger('commands.restart')


async def restart_command(interaction: discord.Interaction):
    await interaction.response.defer()
    
    try:
      rcon_host = os.environ.get('RCON_HOST', 'localhost')
      rcon_port = int(os.environ.get('RCON_PORT', '25575'))
      rcon_password = os.environ['RCON_PASSWORD']
    except KeyError as e:
        logger.error(f'Missing RCON configuration: {str(e)}')
        
        embed = discord.Embed(
            title="Configuration Error",
            description="RCON configuration is missing.",
            color=discord.Color.red()
        )
        await interaction.followup.send(embed=embed)
        return
    
    try:
        with MCRcon(rcon_host, rcon_password, port=rcon_port) as mcr:
            response = mcr.command('stop')
        
        logger.info(f'Restart command executed by {interaction.user} - RCON response: {response}')

        embed = discord.Embed(
            title="Server Restart",
            description="Server stop command executed successfully.",
            color=discord.Color.green()
        )
        await interaction.followup.send(embed=embed)
    except Exception as e:
        logger.error(f'Restart command failed for {interaction.user}: {str(e)}')

        embed = discord.Embed(
            title="Command Failed",
            description="Failed to execute restart command.",
            color=discord.Color.red()
        )
        await interaction.followup.send(embed=embed)


def setup(group: app_commands.Group):
    @group.command(name='restart', description='Stop the Minecraft server')
    async def restart(interaction: discord.Interaction):
        await restart_command(interaction)
