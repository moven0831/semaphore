pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template MerkleTreeInclusionProof(nLevels) {
    signal input leaf;
    signal input pathIndices[nLevels];
    signal input siblings[nLevels];

    signal output root;

    signal hashes[nLevels + 1];
    hashes[0] <== leaf;

    signal mux[nLevels];
    signal merklePath[nLevels][2][2];
    for (var i = 0; i < nLevels; i++) {
        pathIndices[i] * (1 - pathIndices[i]) === 0;

        merklePath[i][0][0] <== hashes[i];
        merklePath[i][0][1] <== siblings[i];

        merklePath[i][1][0] <== siblings[i];
        merklePath[i][1][1] <== hashes[i];

        mux[i] <== MultiMux1(2)(merklePath[i], pathIndices[i]);
        hashes[i + 1] <== Poseidon(2)(mux[i]);
    }

    root <== hashes[nLevels];
}
