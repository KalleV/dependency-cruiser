"use strict";

const fs                 = require("fs");
const validateParameters = require("./validateParameters");
const normalizeOptions   = require("./normalizeOptions");
const initRules          = require("./initRules");
const main               = require("../main");
const formatMetaInfo     = require('./formatMetaInfo');


/* OS pipe buffer size in bytes - which is what ulimit -a tells me on OSX */
const PIPE_BUFFER_SIZE   = 512;

function writeToFile(pOutputTo, pDependencyString) {
    try {
        fs.writeFileSync(
            pOutputTo,
            pDependencyString,
            {encoding: "utf8", flag: "w"}
        );
    } catch (e) {
        process.stderr.write(`ERROR: Writing to '${pOutputTo}' didn't work. ${e}`);
    }
}

/**
 * Writes the string pString to stdout in chunks of pBufferSize size.
 *
 * When writing to a pipe, it's possible that pipe's buffer is full.
 * To prevent this problem from happening we should take the value at which
 * the OS guarantees atomic writes to pipes - which on my OSX machine is
 * 512 bytes. That seems pretty low (I've seen reports of 4k on the internet)
 * so it looks like a safe limit.
 *
 * @param  {string} pString The string to write
 * @param  {number} pBufferSize The size of the buffer to use.
 * @returns {void} nothing
 */
function writeToStdOut(pString, pBufferSize) {
    const lNumberOfChunks = Math.ceil(pString.length / pBufferSize);
    let i = 0;

    for (i = 0; i < lNumberOfChunks; i++) {
        process.stdout.write(pString.substr(i * pBufferSize, pBufferSize));
    }

}

function write(pOutputTo, pContent) {
    if ("-" === pOutputTo) {
        writeToStdOut(pContent, PIPE_BUFFER_SIZE);
    } else {
        writeToFile(pOutputTo, pContent);
    }
}

module.exports = (pFileDirArray, pOptions) => {
    try {
        if (pOptions && pOptions.info === true) {
            process.stdout.write(formatMetaInfo());
        } else if (pOptions && pOptions.initRules === true){
            initRules();
            process.stdout.write(`\n  Successfully created '.dependency-cruiser.json'\n\n`);
        } else {
            validateParameters(pFileDirArray, pOptions);
            pOptions = normalizeOptions(pOptions);

            if (Boolean(pOptions.rulesFile)){
                pOptions.ruleSet = fs.readFileSync(pOptions.rulesFile, 'utf8');
            }

            const lDependencyList = main.cruise(pFileDirArray, pOptions);

            write(pOptions.outputTo, lDependencyList.dependencies);

            /* istanbul ignore if */
            if (lDependencyList.summary.error > 0) {
                process.exit(lDependencyList.summary.error);
            }
        }
    } catch (e) {
        process.stderr.write(`\n  ERROR: ${e.message}\n`);
    }
};

/* eslint no-process-exit: 0 no-plusplus: 0*/
