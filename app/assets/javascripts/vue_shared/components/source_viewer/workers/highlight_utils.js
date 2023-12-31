import hljs from 'highlight.js/lib/core';
import json from 'highlight.js/lib/languages/json';
import { registerPlugins } from '../plugins/index';
import { LINES_PER_CHUNK, NEWLINE, ROUGE_TO_HLJS_LANGUAGE_MAP } from '../constants';

const initHighlightJs = (fileType, content, language) => {
  // The Highlight Worker is currently scoped to JSON files.
  // See the following issue for more: https://gitlab.com/gitlab-org/gitlab/-/issues/415753
  hljs.registerLanguage(language, json);
  registerPlugins(hljs, fileType, content, true);
};

const splitByLineBreaks = (content = '') => content.split(/\r?\n/);

const createChunk = (language, rawChunkLines, highlightedChunkLines = [], startingFrom = 0) => ({
  highlightedContent: highlightedChunkLines.join(NEWLINE),
  rawContent: rawChunkLines.join(NEWLINE),
  totalLines: rawChunkLines.length,
  startingFrom,
  language,
});

const splitIntoChunks = (language, rawContent, highlightedContent) => {
  const result = [];
  const splitRawContent = splitByLineBreaks(rawContent);
  const splitHighlightedContent = splitByLineBreaks(highlightedContent);

  for (let i = 0; i < splitRawContent.length; i += LINES_PER_CHUNK) {
    const chunkIndex = Math.floor(i / LINES_PER_CHUNK);
    const highlightedChunk = splitHighlightedContent.slice(i, i + LINES_PER_CHUNK);
    const rawChunk = splitRawContent.slice(i, i + LINES_PER_CHUNK);
    result[chunkIndex] = createChunk(language, rawChunk, highlightedChunk, i);
  }

  return result;
};

const highlight = (fileType, rawContent, lang) => {
  const language = ROUGE_TO_HLJS_LANGUAGE_MAP[lang.toLowerCase()];
  let result;

  if (language) {
    initHighlightJs(fileType, rawContent, language);
    const highlightedContent = hljs.highlight(rawContent, { language }).value;
    result = splitIntoChunks(language, rawContent, highlightedContent);
  }

  return result;
};

export { highlight, splitIntoChunks };
