#!/bin/bash

set -e

mkdir -p $HOME/.config
cp -r /home/kicad/.config/kicad $HOME/.config/

erc_violation=0 # ERC exit code
drc_violation=0 # DRC exit code

# Run ERC if requested
if [[ -n $INPUT_KICAD_SCH ]] && [[ $INPUT_SCH_ERC = "true" ]]
then
  kicad-cli sch erc \
    --output "`dirname $INPUT_KICAD_SCH`/$INPUT_SCH_ERC_FILE" \
    --format $INPUT_REPORT_FORMAT \
    --exit-code-violations \
    "$INPUT_KICAD_SCH"
  erc_violation=$?
fi

# Export schematic PDF if requested
if [[ -n $INPUT_KICAD_SCH ]] && [[ $INPUT_SCH_PDF = "true" ]]
then
  kicad-cli sch export pdf \
    --output "`dirname $INPUT_KICAD_SCH`/$INPUT_SCH_PDF_FILE" \
    "$INPUT_KICAD_SCH"
fi

# Export schematic BOM if requested
if [[ -n $INPUT_KICAD_SCH ]] && [[ $INPUT_SCH_BOM = "true" ]]
then
  kicad-cli sch export bom \
    --output "`dirname $INPUT_KICAD_SCH`/$INPUT_SCH_BOM_FILE" \
    --preset "$INPUT_SCH_BOM_PRESET" \
    "$INPUT_KICAD_SCH"
fi

# Run DRC if requested
if [[ -n $INPUT_KICAD_PCB ]] && [[ $INPUT_PCB_DRC = "true" ]]
then
  kicad-cli pcb drc \
    --output "`dirname $INPUT_KICAD_PCB`/$INPUT_PCB_DRC_FILE" \
    --format $INPUT_REPORT_FORMAT \
    --exit-code-violations \
    "$INPUT_KICAD_PCB"
  drc_violation=$?
fi

# Export Gerbers if requested
if [[ -n $INPUT_KICAD_PCB ]] && [[ $INPUT_PCB_GERBERS = "true" ]]
then
  GERBERS_DIR=`mktemp -d`
  kicad-cli pcb export gerbers \
    --output "$GERBERS_DIR/" \
    "$INPUT_KICAD_PCB"
  kicad-cli pcb export drill \
    --output "$GERBERS_DIR/" \
    "$INPUT_KICAD_PCB"
  zip -j \
    "`dirname $INPUT_KICAD_PCB`/$INPUT_PCB_GERBERS_FILE" \
    "$GERBERS_DIR"/*
fi

if [[ -n $INPUT_KICAD_PCB ]] && [[ $INPUT_PCB_IMAGE = "true" ]]
then
  mkdir -p "`dirname $INPUT_KICAD_PCB`/$INPUT_PCB_IMAGE_PATH"
  kicad-cli pcb render --side top \
    --output "`dirname $INPUT_KICAD_PCB`/$INPUT_PCB_IMAGE_PATH/top.png" \
    "$INPUT_KICAD_PCB"
  kicad-cli pcb render --side bottom \
    --output "`dirname $INPUT_KICAD_PCB`/$INPUT_PCB_IMAGE_PATH/bottom.png" \
    "$INPUT_KICAD_PCB"
fi

if [[ -n $INPUT_KICAD_PCB ]] && [[ $INPUT_PCB_MODEL = "true" ]]
then
  kicad-cli pcb export step --no-unspecified  --include-tracks  --include-pads  --include-zones --no-dnp --no-optimize-step \
    --output "`dirname $INPUT_KICAD_PCB`/$INPUT_PCB_MODEL_FILE" \
    "$INPUT_KICAD_PCB"
fi

# Return non-zero exit code for ERC or DRC violations
if [[ $erc_violation -gt 0 ]] || [[ $drc_violation -gt 0 ]]
then
  exit 1
else
  exit 0
fi
