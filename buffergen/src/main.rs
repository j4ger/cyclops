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
    let scaled_image = input_file.resize(640, 480, image::imageops::FilterType::Triangle);
    let image_buffer = scaled_image.as_rgb8().expect("Failed to get image buffer");

    let mut output_bytes: Vec<String> = Vec::new();

    println!(
        "Target dimensions: {}x{}",
        image_buffer.width(),
        image_buffer.height()
    );

    for (_, _, pixel) in image_buffer.enumerate_pixels() {
        let mut partial = pixel.0.map(|x| format!("{:x}", x)).join("");
        partial.push('0');
        partial.push('0');
        output_bytes.push(partial);
    }

    let output_file = matches
        .get_one::<String>("output")
        .expect("Failed to parse output path");
    let mut output_file = File::create(output_file).expect("Failed to create output file");
    output_file
        .write_all(output_bytes.join(" ").as_bytes())
        .expect("Failed to write");
}
