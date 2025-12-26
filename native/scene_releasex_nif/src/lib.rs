use rustler::{Env, Error, Term};
use rustler::Encoder;
use scene_release::parser::ReleaseParser;
use scene_release::types::PathInfo;

rustler::init!("Elixir.SceneReleasex");

#[rustler::nif(name = "nif_parse")]
fn parse(env: Env<'_>, release_type: String, release_name: String) -> Result<Term<'_>, Error> {
    let parser = ReleaseParser::new(&release_type);
    let parsed = parser.parse(&release_name);
    serialize_parsed_release(env, &parsed)
}

#[rustler::nif(name = "nif_parse_path")]
fn parse_path(env: Env<'_>, release_type: String, file_path: String) -> Result<Term<'_>, Error> {
    let parser = ReleaseParser::new(&release_type);
    let path_info = parser.parse_path(&file_path);

    match path_info {
        Some(info) => serialize_path_info(env, &info),
        None => Err(Error::RaiseTerm(Box::new("failed to parse path".to_string()))),
    }
}

#[rustler::nif(name = "nif_parse_series_directory")]
fn parse_series_directory(env: Env<'_>, directory_name: String) -> Result<Term<'_>, Error> {
    let parser = ReleaseParser::new("series");
    let parsed = parser.parse_series_directory(&directory_name);
    serialize_parsed_release(env, &parsed)
}

#[rustler::nif(name = "nif_parse_movie_directory")]
fn parse_movie_directory(env: Env<'_>, directory_name: String) -> Result<Term<'_>, Error> {
    let parser = ReleaseParser::new("movie");
    let parsed = parser.parse_movie_directory(&directory_name);
    serialize_parsed_release(env, &parsed)
}

#[rustler::nif(name = "nif_parse_season_directory")]
fn parse_season_directory(env: Env<'_>, directory_name: String) -> Result<Term<'_>, Error> {
    let parser = ReleaseParser::new("tv");
    let season = parser.parse_season_directory(&directory_name);
    match season {
        Some(s) => Ok((s as u64).encode(env)),
        None => Ok(rustler::types::atom::nil().encode(env)),
    }
}

fn serialize_parsed_release<'a>(env: Env<'a>, parsed: &scene_release::types::ParsedRelease) -> Result<Term<'a>, Error> {
    let mut pairs: Vec<(Term<'a>, Term<'a>)> = Vec::new();

    pairs.push(("release".encode(env), parsed.release.encode(env)));
    pairs.push(("title".encode(env), parsed.title.encode(env)));
    pairs.push(("title_extra".encode(env), parsed.episode_title.encode(env)));
    pairs.push(("group".encode(env), parsed.group.encode(env)));

    match parsed.year {
        Some(year) => pairs.push(("year".encode(env), (year as i64).encode(env))),
        None => pairs.push(("year".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match &parsed.date {
        Some(date) => pairs.push(("date".encode(env), date.as_str().encode(env))),
        None => pairs.push(("date".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match parsed.season {
        Some(season) => pairs.push(("season".encode(env), (season as i64).encode(env))),
        None => pairs.push(("season".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match parsed.episode {
        Some(episode) => pairs.push(("episode".encode(env), (episode as i64).encode(env))),
        None => pairs.push(("episode".encode(env), rustler::types::atom::nil().encode(env))),
    }

    let episodes: Vec<i64> = parsed.episodes.iter().map(|&e| e as i64).collect();
    pairs.push(("episodes".encode(env), episodes.encode(env)));

    match parsed.disc {
        Some(disc) => pairs.push(("disc".encode(env), (disc as i64).encode(env))),
        None => pairs.push(("disc".encode(env), rustler::types::atom::nil().encode(env))),
    }

    let flags: Vec<&str> = parsed.flags.iter().map(|s| s.as_str()).collect();
    pairs.push(("flags".encode(env), flags.encode(env)));

    pairs.push(("source".encode(env), parsed.source.encode(env)));
    pairs.push(("format".encode(env), parsed.format.encode(env)));
    pairs.push(("resolution".encode(env), parsed.resolution.encode(env)));
    pairs.push(("audio".encode(env), parsed.audio.encode(env)));
    pairs.push(("device".encode(env), parsed.device.encode(env)));
    pairs.push(("os".encode(env), parsed.os.encode(env)));
    pairs.push(("version".encode(env), parsed.version.encode(env)));

    let mut lang_pairs: Vec<(Term<'a>, Term<'a>)> = Vec::new();
    for (lang_code, lang_name) in &parsed.language {
        lang_pairs.push((lang_code.as_str().encode(env), lang_name.as_str().encode(env)));
    }
    let language_map = Term::map_from_pairs(env, &lang_pairs)?;
    pairs.push(("language".encode(env), language_map));

    match &parsed.tmdb_id {
        Some(tmdb_id) => pairs.push(("tmdb_id".encode(env), tmdb_id.as_str().encode(env))),
        None => pairs.push(("tmdb_id".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match &parsed.tvdb_id {
        Some(tvdb_id) => pairs.push(("tvdb_id".encode(env), tvdb_id.as_str().encode(env))),
        None => pairs.push(("tvdb_id".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match &parsed.imdb_id {
        Some(imdb_id) => pairs.push(("imdb_id".encode(env), imdb_id.as_str().encode(env))),
        None => pairs.push(("imdb_id".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match &parsed.edition {
        Some(edition) => pairs.push(("edition".encode(env), edition.as_str().encode(env))),
        None => pairs.push(("edition".encode(env), rustler::types::atom::nil().encode(env))),
    }

    pairs.push(("hdr".encode(env), parsed.hdr.encode(env)));
    pairs.push(("streaming_provider".encode(env), parsed.streaming_provider.encode(env)));
    pairs.push(("type".encode(env), parsed.release_type.encode(env)));

    Term::map_from_pairs(env, &pairs)
}

fn serialize_path_info<'a>(env: Env<'a>, path_info: &PathInfo) -> Result<Term<'a>, Error> {
    let mut pairs: Vec<(Term<'a>, Term<'a>)> = Vec::new();

    match &path_info.directory {
        Some(directory) => {
            let dir_map = serialize_parsed_release(env, directory)?;
            pairs.push(("directory".encode(env), dir_map));
        }
        None => pairs.push(("directory".encode(env), rustler::types::atom::nil().encode(env))),
    }

    match path_info.season {
        Some(season) => pairs.push(("season".encode(env), (season as i64).encode(env))),
        None => pairs.push(("season".encode(env), rustler::types::atom::nil().encode(env))),
    }

    let file_map = serialize_parsed_release(env, &path_info.file)?;
    pairs.push(("file".encode(env), file_map));

    pairs.push(("full_path".encode(env), path_info.full_path.encode(env)));

    Term::map_from_pairs(env, &pairs)
}
