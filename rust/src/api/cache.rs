use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};

use futures::StreamExt as _;
use tokio::io::AsyncWriteExt as _;

use super::ROOT_PATH;

// 生成哈希值作为文件名
#[flutter_rust_bridge::frb]
pub fn gen_hash(str_: &str) -> String {
    let mut hasher = DefaultHasher::new();
    str_.hash(&mut hasher);
    format!("{:x}", hasher.finish())
}

#[flutter_rust_bridge::frb]
pub async fn cache_file(
    file: &str,
    cache_path: &str,
    filename: Option<String>,
) -> Result<String, anyhow::Error> {
    let filename = match filename {
        None => gen_hash(file),
        Some(filename) => filename.to_string(),
    };
    let root = ROOT_PATH.read().await;
    let mut root_path = root.clone();
    root_path.push(cache_path);

    if !root_path.exists() {
        tokio::fs::create_dir_all(&root_path).await?;
    }

    let filepath = root_path.join(&filename);

    if file.starts_with("http") {
        let response = reqwest::get(file).await?;
        let mut stream = response.bytes_stream();

        let mut file = tokio::fs::File::create(&filepath).await?;

        while let Some(chunk) = stream.next().await {
            let data = chunk?;
            file.write_all(&data).await?;
        }
    } else {
        tokio::fs::copy(file, &filepath).await?;
    }

    Ok(filepath.to_string_lossy().into_owned())
}

#[flutter_rust_bridge::frb]
pub async fn use_cache_file(
    file: &str,
    cache_path: &str,
    filename: Option<String>,
) -> Option<String> {
    let filename = match filename {
        None => gen_hash(file),
        Some(filename) => filename.to_string(),
    };
    let root = ROOT_PATH.read().await;
    let mut root_path = root.clone();
    root_path.push(cache_path);
    let filepath = root_path.join(&filename);

    if filepath.exists() {
        Some(filepath.to_string_lossy().into_owned())
    } else {
        None
    }
}

#[flutter_rust_bridge::frb]
pub async fn delete_cache_file(
    file: &str,
    cache_path: &str,
    filename: Option<String>,
) -> Result<(), anyhow::Error> {
    let filename = match filename {
        None => gen_hash(file),
        Some(filename) => filename.to_string(),
    };
    let root = ROOT_PATH.read().await;
    let mut root_path = root.clone();
    root_path.push(cache_path);
    let filepath = root_path.join(&filename);

    if filepath.exists() {
        tokio::fs::remove_file(&filepath).await?;
        Ok(())
    } else {
        Err(anyhow::Error::new(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            "File not found",
        )))
    }
}
