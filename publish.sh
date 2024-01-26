#!/usr/bin/env bash

  # Remove all edit formatting can use regex \\review\{.+?\}\{(.+?)\} $1 but watch out.
# TODO use arxiv-latex-cleaner to do this.
build="../build"
paper="paper"  # Note must match the name in the Makefile.

# Make sure everything is committed.
if [[ `git status --porcelain --untracked-files=no` ]]; then
  echo "WARNING: Working copy contains uncommitted changes"
  # exit 1
fi

# Don't accept any errors from here on.
set -euo pipefail

# Remove ../build folder.
touch "${build}"
rm -r "${build}"

# Clean out all comments
pip install arxiv-latex-cleaner
# if in the master folder this cretes a folder ../master_arXiv
echo "Clean with arxiv_latex_cleaner..."
arxiv_latex_cleaner --verbose --keep_bib --config cleaner_config.yaml .
mv "../master_arXiv" "${build}"
echo "Clean with arxiv_latex_cleaner complete."

# Test build
echo "Test build..."
pushd "${build}"
rm cleaner_config.yaml
make
echo "Test build complete."

# Copy paper pdf file to parent folder
cp "${paper}".pdf ..

# Remove 'analysis' folder if it exists
if [ -d analysis ]; then
  rm -r analysis
fi

# Create compressed paper version ${paper}-compressed.pdf
# This is placed in the parent folder.
echo "Compressing..."
echo "Creating compressed paper version ${paper}-compressed.pdf"
make compressed
echo "Compressing complete."
mv "${paper}-compressed".pdf ..

# Create tarball of sources suitable for upload to both arXiv and publisher
echo "Create tarball..."
echo "Creating tarball named ${paper}-sources.tar.gz"
make clean
tar -czvf "../${paper}-sources.tar.gz" .
ls -lh ..
echo "Create tarball complete."

# Do a test unpack in temp folder
if [ -d ../test-unpack ]; then
  rm -r ../test-unpack
fi
mkdir ../test-unpack
cd ../test-unpack
cp ../"${paper}"-sources.tar.gz .
tar -xzvf "${paper}"-sources.tar.gz


popd
echo "Finished :-)"
exit 0



