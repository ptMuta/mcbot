import logging
import importlib
from pathlib import Path
from discord import app_commands

logger = logging.getLogger('mcbot.commands')

def load_commands(tree):
    commands_dir = Path(__file__).parent
    
    mcbot_group = app_commands.Group(name='mcbot', description='Minecraft server control commands')
    
    for file in commands_dir.glob('*.py'):
        if file.name.startswith('_'):
            continue
        
        module_name = file.stem
        module = importlib.import_module(f'commands.{module_name}')
        
        if hasattr(module, 'setup'):
            module.setup(mcbot_group)
            logger.info(f'Loaded command module: {module_name}')
    
    tree.add_command(mcbot_group)

