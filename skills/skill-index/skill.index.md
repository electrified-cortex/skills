# Skill Index

A cascading per-directory index system for agent skill discovery.

## skill-index

Root entry for the skill-index toolkit — lets agents find skills by reading compact index nodes.

## skill-index-auditing

Validates a skill-index cascade; returns ok, rebuild-needed, or inconclusive.

## skill-index-building

Builds or rebuilds the raw index and overlay at each directory in a skill tree.

## skill-index-crawling

Reads an existing cascade to locate the skill matching a stated need.

## skill-index-integration

Wires the skill-index cascade into an agent — sets the index pointer, writes the discovery mandate, and enforces demand loading.
