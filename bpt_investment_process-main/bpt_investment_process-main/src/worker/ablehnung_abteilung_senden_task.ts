// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ablehnungAbteilungSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ablehnung-abteilung-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ablehnung_abteilung_erhalten_message",
          correlationKey: "ablehnung_abteilung_erhalten_key",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  