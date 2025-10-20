#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Imagenation Package Testing Script ===${NC}\n"

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Clean up function
cleanup() {
    print_info "Cleaning up test environment..."
    if [ -d "test_venv" ]; then
        rm -rf test_venv
    fi
    if [ -d "test_install" ]; then
        rm -rf test_install
    fi
}

# Set up trap to cleanup on exit
trap cleanup EXIT

# Step 1: Install build tools in current venv if needed
print_section "Step 1: Checking Build Tools"
print_info "Ensuring build tools are installed..."
pip install build twine check-manifest -q --upgrade
print_status $? "Build tools ready"

# Step 2: Clean previous builds
print_section "Step 2: Cleaning Previous Builds"
if [ -d "dist" ]; then
    print_info "Removing old dist/ directory..."
    rm -rf dist
fi
if [ -d "build" ]; then
    print_info "Removing old build/ directory..."
    rm -rf build
fi
if [ -d "*.egg-info" ]; then
    rm -rf *.egg-info
fi
print_status 0 "Clean completed"

# Step 3: Validate MANIFEST.in
print_section "Step 3: Validating MANIFEST.in"
check-manifest --ignore "venv,test_venv,test_install,.git,.gitignore,*.pyc,__pycache__,images,start.sh,imagenation.py" 2>&1
MANIFEST_STATUS=$?
if [ $MANIFEST_STATUS -eq 0 ]; then
    print_status 0 "MANIFEST.in is correct"
else
    print_status 1 "MANIFEST.in has issues"
fi

# Step 4: Build the package
print_section "Step 4: Building Package"
python -m build 2>&1 | grep -v "^$"
print_status ${PIPESTATUS[0]} "Package built successfully"

# Step 5: Check package metadata
print_section "Step 5: Checking Package Metadata"
twine check dist/*
print_status $? "Package metadata is valid"

# Step 6: Inspect package contents
print_section "Step 6: Inspecting Package Contents"
echo -e "\n${YELLOW}Wheel contents:${NC}"
unzip -l dist/*.whl | grep -E "(imagenation/|README|LICENSE|banner)"
echo -e "\n${YELLOW}Source distribution contents:${NC}"
tar -tzf dist/*.tar.gz | grep -E "(imagenation/|README|LICENSE|banner)" | head -20

# Step 7: Create isolated test environment
print_section "Step 7: Creating Test Environment"
print_info "Creating fresh virtual environment..."
python -m venv test_venv
print_status $? "Test venv created"

# Step 8: Install package in test environment
print_section "Step 8: Installing Package in Test Environment"
print_info "Installing from wheel..."
./test_venv/bin/pip install dist/*.whl -q
print_status $? "Package installed successfully"

# Step 9: Test imports
print_section "Step 9: Testing Python Imports"
./test_venv/bin/python -c "from imagenation import ImagenationGenerator; print('✓ Import successful')" 2>&1
print_status $? "Python imports work correctly"

./test_venv/bin/python -c "import imagenation; print(f'✓ Version: {imagenation.__version__}')" 2>&1
print_status $? "Version accessible"

# Step 10: Test CLI entry point
print_section "Step 10: Testing CLI Entry Point"
./test_venv/bin/imagenation --help > /dev/null 2>&1
print_status $? "CLI command 'imagenation' is available"

# Step 11: Test module execution
print_section "Step 11: Testing Module Execution"
./test_venv/bin/python -m imagenation --help > /dev/null 2>&1
print_status $? "Module execution 'python -m imagenation' works"

# Step 12: Check installed files
print_section "Step 12: Verifying Installed Files"
SITE_PACKAGES=$(./test_venv/bin/python -c "import site; print(site.getsitepackages()[0])")
if [ -d "$SITE_PACKAGES/imagenation" ]; then
    print_status 0 "Package directory exists"
    echo -e "\n${YELLOW}Installed files:${NC}"
    ls -la "$SITE_PACKAGES/imagenation/"
else
    print_status 1 "Package directory not found"
fi

# Step 13: Summary
print_section "Test Summary"
echo -e "${GREEN}All tests passed! ✓${NC}"
echo -e "\nYour package is ready for upload!"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Upload to TestPyPI: ${BLUE}twine upload --repository testpypi dist/*${NC}"
echo -e "2. Upload to PyPI: ${BLUE}twine upload dist/*${NC}"
echo -e "\n${YELLOW}Built files:${NC}"
ls -lh dist/

echo -e "\n${BLUE}=== Testing Complete ===${NC}\n"
