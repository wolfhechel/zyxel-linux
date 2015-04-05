try:
    import ez_setup

    ez_setup.use_setuptools()
except ImportError:
    pass

from setuptools import setup, find_packages

setup(
    name='zynfw',
    version='0.1',
    packages=find_packages(),
    license='MIT',
    author='Pontus Karlsson',
    author_email='jonet@okuejina.net',
    description='Zyxel Firmware Utilities',
    install_requires=[
        'pyserial',
        'xmodem'
    ],
    scripts=[
        'zynfw.py'
    ]
)
