const emojiFromWord = require('emoji-from-word');

const emojiEcho = async (params) => {
    if(!params.word) {
        return '';
    }

    const res = emojiFromWord(params.word);
    if(res.score == 1) {
        return res.emoji.char;
    }

    return '';
};

module.exports = (params) => {
    return emojiEcho(params)
        .catch(() => {
            let match = new RegExp('^.*' + __filename + '.*$', 'gi').exec(error.stack)
            return `[ERROR ${match[0]}]`
        });
}
