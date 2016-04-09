try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

setup(
    name='zynfw',
    version='',
    url='',
    license='',
    author='Pontus Karlsson',
    author_email='jonet@okuejina.net',
    install_requires=[
        'pyserial<3',
        'xmodem',
        'progressbar2'
    ],
    description='',
    scripts=[
        'zynfw.py'
    ]
)
