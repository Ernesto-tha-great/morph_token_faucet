"use client";

import { Button } from "@/components/ui/button";
import { faucetAbi, faucetAddress } from "@/constants";
import { useEffect } from "react";
import { toast } from "sonner";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { useWaitForTransactionReceipt, useWriteContract } from "wagmi";
import { Input } from "@/components/ui/input";

export default function Home() {
  const {
    data: hash,
    isPending,
    error,
    writeContractAsync,
  } = useWriteContract();

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  useEffect(() => {
    if (isConfirmed) {
      toast.success("Transaction Successful", {
        action: {
          label: "View on Etherscan",
          onClick: () => {
            window.open(`https://explorer-holesky.morphl2.io/tx/${hash}`);
          },
        },
      });
    }
    if (error) {
      toast.error("Transaction Failed: " + error.message);
    }
  }, [isConfirming, isConfirmed, error, hash]);

  const formSchema = z.object({
    address: z.string(),
  });

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      address: "",
    },
  });

  const onClaim = async (data: z.infer<typeof formSchema>) => {
    let regex = new RegExp(/^(0x)?[0-9a-fA-F]{40}$/);

    if (!regex.test(data.address)) {
      toast.error("Invalid Ethereum address");
      return;
    }

    try {
      const faucetClaimTx = await writeContractAsync({
        address: faucetAddress,
        abi: faucetAbi,
        functionName: "withdraw",
        args: [data.address],
      });

      console.log("property transaction hash:", faucetClaimTx);
    } catch (err: any) {
      toast.error("Transaction Failed: " + err.message);
      console.log("Transaction Failed: " + err.message);
    }
  };
  return (
    <main className="flex flex-col h-screen items-center justify-center">
      <section className="py-12 flex flex-col items-center text-center gap-8">
        <h1 className="text-4xl font-bold">Morph Holesky Faucet</h1>
        <p className="text-2xl text-muted-foreground">
          Claim testnet ETH to your wallet. You can only claim 0.1ETH per day.
        </p>
      </section>

      <section className="flex flex-col items-center justify-center w-full">
        <div className="w-full max-w-xl p-8  bg-slate-800 shadow-lg rounded-lg">
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onClaim)} className="w-full">
              <FormField
                control={form.control}
                name="address"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>
                      <h1 className="">Morph Holesky Address</h1>
                    </FormLabel>
                    <FormControl>
                      <Input
                        className="rounded-full w-full"
                        placeholder="0x..."
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <Button
                className="bg-[#007A86] mt-8 rounded-full w-full"
                size="lg"
                disabled={isPending}
                type="submit"
              >
                {isPending ? "Loading..." : "Submit"}
              </Button>
            </form>
          </Form>
        </div>
      </section>
    </main>
  );
}
