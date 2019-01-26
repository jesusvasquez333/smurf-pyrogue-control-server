FROM jesusvasquez333/smurf-rogue:R1.0.0

# Install the SMURF PCIe card repository
WORKDIR /usr/local/src
RUN git clone https://github.com/slaclab/smurf-pcie.git
ENV PYTHONPATH /usr/local/src/smurf-pcie/software/python:${PYTHONPATH}
ENV PYTHONPATH /usr/local/src/smurf-pcie/firmware/submodules/axi-pcie-core/python:${PYTHONPATH}

# Install pyrogue-control-server (version R1.3.0)
WORKDIR /usr/local/src
RUN git clone https://github.com/slaclab/pyrogue-control-server.git -b R1.4.0
WORKDIR pyrogue-control-server


# Run the control server using the user arguments
CMD ./start_server.sh ${SERVER_ARGS}

# Ports used by the EPICS server
EXPOSE 5064 5065 5064/udp 5065/udp