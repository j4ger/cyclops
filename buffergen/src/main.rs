use clap::{command, Arg};

use image::io::Reader as ImageReader;
use std::{fs::File, io::prelude::*};

fn main() {
    let matches = command!()
        .arg(Arg::new("input").short('i').long("input").required(true))
        .arg(
            Arg::new("output")
                .short('o')
                .long("output")
                .default_value("buffer.hex"),
        )
        .get_matches();
    let input_file = matches
        .get_one::<String>("input")
        .expect("No valid input provided");
    let input_file = ImageReader::open(input_file)
        .expect("Failed to open file")
        .decode()
        .expect("Failed to decode image");
    let scaled_image = input_file.resize(640, 480, image::imageops::FilterType::Nearest);
    let image_buffer = scaled_image.as_rgb8().expect("Failed to get image buffer");

    let mut output_bytes: Vec<String> = Vec::new();

    let actual_width = image_buffer.width();
    let actual_height = image_buffer.height();

    println!("Target dimensions: {}x{}", actual_width, actual_height);

    for y in 0..2u32.pow(9) {
        for x in 0..2u32.pow(10) {
            if x < actual_width && y < actual_height {
                let pixel = image_buffer.get_pixel(x, y).0;
                output_bytes.push(format!("{:X}{:X}{:X}00", pixel[0], pixel[1], pixel[2]));
            } else {
                output_bytes.push("00000000".to_string());
            }
        }
    }

    let output_file = matches
        .get_one::<String>("output")
        .expect("Failed to parse output path");
    let mut output_file = File::create(output_file).expect("Failed to create output file");
    output_file
        .write_all(output_bytes.join(" ").as_bytes())
        .expect("Failed to write");
}
