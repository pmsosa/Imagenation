# Imagenation 🎨

AI Image Generation Tool using Google's Imagen model. Generate images from text prompts with optional image inputs.

## Features

- **Text-to-Image**: Generate images from text descriptions
- **Text+Image-to-Image**: Modify existing images with text prompts  
- **CLI Interface**: Direct command-line usage
- **Batch Processing**: Process multiple images from CSV/JSON files
- **Library Support**: Import and use in your Python projects

## Quick Start

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Set up API key** in `.env`:
   ```
   GOOGLE_API_KEY=your_api_key_here
   ```

3. **Generate an image**:
   ```bash
   ./start.sh -it "A beautiful sunset over mountains" -o sunset.png
   ```

## Usage

### Command Line

```bash
# Text to image
./start.sh -it "A majestic dragon in a fantasy landscape" -o dragon.png

# Text + image to image  
./start.sh -it "Add a rainbow to this landscape" -ii photo.jpg -o rainbow_photo.png

# Batch processing from CSV
./start.sh --csv batch_data.csv

# Batch processing from JSON
./start.sh --json batch_data.json
```

### Python Library

```python
from imagenation import ImagenationGenerator

# Initialize generator
gen = ImagenationGenerator()

# Generate text-to-image
gen.generate_text_to_image("A serene lake at sunset", "lake.png")

# Generate text+image-to-image
gen.generate_text_image_to_image(
    "Make this photo look vintage", 
    "input.jpg", 
    "vintage_output.jpg"
)
```

### Alternative Usage

```bash
# Using Python module directly
python -m imagenation -it "Beautiful landscape" -o output.png

# Using original script (backward compatibility)
python imagenation.py -it "Beautiful landscape" -o output.png
```

## File Formats

### CSV Format
```csv
input_text,input_image_path,output_image_name
"A beautiful sunset","","sunset.png"
"Add a rainbow","landscape.jpg","rainbow_landscape.png"
```

### JSON Format
```json
[
  {
    "input_text": "A beautiful sunset",
    "input_image_path": "",
    "output_image_name": "sunset.png"
  },
  {
    "input_text": "Add a rainbow", 
    "input_image_path": "landscape.jpg",
    "output_image_name": "rainbow_landscape.png"
  }
]
```

## Requirements

- Python 3.7+
- Google API key with Gemini access
- Dependencies: `google-genai`, `pillow`, `python-dotenv`

## Project Structure

```
imagenation/
├── imagenation/           # Main package
│   ├── __init__.py       # Package exports
│   ├── generator.py      # Core generation logic
│   ├── cli.py           # Command-line interface
│   └── __main__.py      # Module entry point
├── imagenation.py        # Backward compatibility script
├── start.sh             # Setup and run script
├── requirements.txt     # Dependencies
├── .env                # API key configuration
└── README.md           # This file
```